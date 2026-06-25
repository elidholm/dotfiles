---
name: python-testing
description: >
  Guide for writing Python unit and component tests in.
  Use when asked to write, review, generate, or fix Python tests.
---

# Python Testing

## Context

- Framework: **`unittest`** — never pytest.
- Mocking: **`unittest.mock`** — `patch`, `MagicMock`, `Mock`.
- Line length: **119 characters** (ruff, mypy, pylint all configured to this).
- Quotes: **double quotes** (ruff format).

---

## Test Types

### Unit Tests

Test a single function, method, or class **in isolation**:

- Mock **all** external dependencies (network, DB, vault, filesystem where meaningful).
- Run fast and independently — no side effects between tests.
- Target specific behaviours and edge cases.

### Component Tests

Test how **multiple internal modules interact**:

- Real instances of internal classes are allowed (no need to mock everything).
- Still mock external services: Vault, Gerrit, Jenkins, Redis, Azure APIs, etc.
- Verify realistic usage scenarios and dependency injection patterns.
- May contain multiple test classes in one file (e.g. `TestFooIntegration`, `TestFooConsistency`).

---

## Directory & Naming Conventions

```text
<app-or-lib>/
└── tests/
    ├── unit/
    │   └── test_<module_name>.py           # e.g. test_config.py
    └── component/
        └── test_<module_name>_component.py  # e.g. test_config_component.py
```

- **Nested source modules**: replace path separators with underscores.
  - `models/azure.py` → `test_models_azure.py`
  - `batching/secrets.py` → `test_batching_secrets.py`
- **⚠ Never duplicate a module name** across `unit/` and `component/` — it causes mypy import conflicts.

---

## Test File Skeleton

```python
"""Unit tests for the <module> module."""

import unittest
from unittest.mock import MagicMock, patch

from scoop.<module> import MyClass


class TestMyClass(unittest.TestCase):
    """Test cases for the MyClass class."""

    def setUp(self):
        """Set up a fresh instance for each test."""
        self.instance = MyClass()

    def tearDown(self):
        """Clean up resources after each test."""
        # release any resources acquired in setUp

    def test_<behaviour>(self):
        """Test that <behaviour> works as expected."""
        result = self.instance.some_method("input")
        self.assertEqual(result, "expected")
```

---

## Common Assertions

| Assertion | When to use |
| --------- | ----------- |
| `assertEqual(a, b)` | Exact equality |
| `assertNotEqual(a, b)` | Values differ |
| `assertTrue(x)` / `assertFalse(x)` | Boolean result |
| `assertIsNone(x)` / `assertIsNotNone(x)` | None check |
| `assertIn(a, b)` / `assertNotIn(a, b)` | Membership |
| `assertIsInstance(obj, Type)` | Type check |
| `assertGreater(a, b)` / `assertGreaterEqual(a, b)` | Numeric comparison |
| `assertIsNot(a, b)` | Identity — two different objects |
| `assertRaises(Exc)` | Exception is raised (context manager form) |

---

## Mocking Patterns

### Basic `@patch` decorator

Patch where the name is **used**, not where it is defined:

```python
@patch("scoop.batching.secrets.ScoopConfig")
@patch("scoop.batching.secrets.get_secret")
def test_read_vault_secrets(self, mock_get_secret, mock_scoop_config):
    # Decorators apply bottom-up; args are passed left-to-right (innermost first)
    mock_config = MagicMock()
    mock_config.get.return_value = "gerrit.example.com"
    mock_scoop_config.return_value = mock_config

    mock_get_secret.side_effect = lambda path: {
        "artcspci": {"username": "vault_user", "jenkins_token": "vault_token"},
        "services": {"gerrit.example.com": {"ssh_user": "git_user", "ssh_key": "git_key"}},
        "tyrosh": {"jenkins_token": "tyrosh_token"},
    }[path]

    result = Secrets()

    mock_get_secret.assert_any_call("artcspci")
    mock_config.get.assert_called_once_with("gerrit", "url")
    self.assertEqual(result.artcspci_username.get_secret_value(), "vault_user")
```

### `Mock(spec=ClassName)` — preferred for objects

Use `spec=` to catch typos and wrong attribute access at test time:

```python
from unittest.mock import Mock
from scoop.models.gerrit import Patchset

mock_patch = Mock(spec=Patchset)
mock_patch.project = "project-a"
mock_patch.has_submit_requirement.return_value = True
```

### `side_effect` forms

```python
# Raise an exception
mock_fn.side_effect = ValueError("bad input")

# Sequential return values
mock_fn.side_effect = ["first", "second", "third"]

# Dynamic behaviour
mock_fn.side_effect = lambda x: x * 2
```

### Mock call assertions

```python
mock_fn.assert_called()                              # called at least once
mock_fn.assert_called_once_with(arg1, kwarg="val")   # called exactly once with these args
mock_fn.assert_any_call("some_path")                 # called at least once with these args
self.assertEqual(mock_fn.call_count, 3)              # exact call count
args, kwargs = mock_fn.call_args                     # inspect last call
```

### Context manager style

```python
def test_something(self):
    with patch("module.function") as mock_fn:
        mock_fn.return_value = "mocked"
        result = code_under_test()
    self.assertEqual(result, "mocked")
```

---

## Specialised Patterns

### Temporary files and directories

```python
import tempfile
from pathlib import Path

def setUp(self):
    self.temp_dir = tempfile.TemporaryDirectory()
    self.test_dir = Path(self.temp_dir.name)

def tearDown(self):
    self.temp_dir.cleanup()

def test_file_operation(self):
    test_file = self.test_dir / "data.txt"
    test_file.write_text("content")
    # exercise code under test...
    self.assertTrue(test_file.exists())
```

### Testing exceptions with message checks

```python
def test_invalid_path(self):
    with self.assertRaises(KeyError) as ctx:
        self.config.get("nonexistent", "key")
    self.assertIn("nonexistent -> key", str(ctx.exception))
```

### Testing context managers

```python
def test_context_manager(self):
    original = Path.cwd()
    with workspace.chdir(sub_dir) as path:
        self.assertEqual(Path.cwd(), sub_dir)
        self.assertEqual(path, sub_dir)
    self.assertEqual(Path.cwd(), original)  # restored after exit

def test_context_manager_exception_safety(self):
    original = Path.cwd()
    try:
        with workspace.chdir(sub_dir):
            raise ValueError("test")
    except ValueError:
        pass
    self.assertEqual(Path.cwd(), original)  # still restored
```

### Pydantic model validation

```python
from pydantic import ValidationError

def test_invalid_model(self):
    with self.assertRaises(ValidationError):
        VmData(disk_size=-1, ...)  # negative size violates validator
```

### Parametrised assertions with `subTest`

```python
def test_url_format(self):
    cases = [("staging", "https://staging.example.com"), ("prod", "https://prod.example.com")]
    for name, url in cases:
        with self.subTest(env=name):
            self.assertTrue(url.startswith("https://"))
            self.assertFalse(url.endswith("/"))
```

### Private helper methods

Extract repeated assertion logic into `_check_*` methods on the test class:

```python
def _check_required_fields(self, section_name, config_section, required_fields):
    for field in required_fields:
        self.assertIn(field, config_section, f"{section_name} must have '{field}'")
```

---

## Component Test Guidelines

```python
"""Component tests for the config module."""

import unittest
from scoop.config import ScoopConfig
from scoop.models.vault import CSMVault


class TestScoopConfigIntegration(unittest.TestCase):
    """Component tests for ScoopConfig integration with other modules."""

    def setUp(self):
        self.config = ScoopConfig()

    def test_vault_type_integration(self):
        """Test that vault config integrates with the vault model."""
        vault_type = self.config.get("vault", "type")
        self.assertEqual(vault_type, CSMVault)
        instance = vault_type()
        self.assertIsInstance(instance, CSMVault)

    def test_multiple_instances_are_independent(self):
        """Test that two ScoopConfig instances don't share state."""
        config2 = ScoopConfig()
        self.assertIsNot(self.config, config2)
        self.assertEqual(self.config.get("vault"), config2.get("vault"))
```

---

## Running Tests

```bash
# Run all tests
python -m unittest discover -s tests

# Run all unit tests
python -m unittest discover -s tests/unit

# Run all component tests
python -m unittest discover -s tests/component

# Run a single test file
python -m unittest tests/unit/test_module_name.py

# Run a single test method
python -m unittest tests/unit/test_module_name.py.TestClassName.test_case_name
```

---

## Do's and Don'ts

### Do

1. **One behaviour per test method** — keep tests focused and easy to debug.
2. **Descriptive method names** — `test_returns_default_when_key_missing` beats `test_get`.
3. **Docstrings on every test** — they serve as living documentation.
4. **Mock all external dependencies** in unit tests — network, Vault, Gerrit, Redis, filesystem.
5. **Test edge cases** — empty inputs, missing keys, negative values, permission errors.
6. **Clean up resources** — use `tearDown` or context managers for temp dirs and mocks.
7. **Separate unit and component tests** — different files, different directories.

### Don't

1. **No live external calls** — tests must run without network or service access.
2. **No implementation-detail testing** — test the public interface and observable behaviour.
3. **No time-dependent assertions** — avoid `time.sleep()` and exact timestamp checks.
4. **No inter-test dependencies** — each test must pass independently in any order.
5. **No global state** — reset all state in `setUp`/`tearDown`.
6. **No mixing unit and component tests** in the same file.
7. **No duplicate module names** across `unit/` and `component/` directories.
