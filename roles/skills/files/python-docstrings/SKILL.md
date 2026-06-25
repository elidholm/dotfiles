---
name: python-docstrings
description: >
  Guide for writing Python docstrings and type hints.
  Use when asked to write, review, or add docstrings, type annotations, or
  type hints to Python modules, classes, functions, or methods.
---

# Python Docstrings and Type Hints

## Context

- **Docstring style**: Google style with `Args:`, `Returns:`, `Raises:`, `Yields:`, `Attributes:`, `Note:`, and `Example:` sections.
- **Type hinting**: Always annotate public functions and methods. Use `from typing import ...` — not bare built-ins like `dict[...]` or `list[...]`.
- **Forward references / self-referential types**: Add `from __future__ import annotations` at the top of the file.
- **Line length**: 119 characters.
- **Quotes**: Double quotes everywhere (ruff format).

---

## Module Docstrings

Every module (except empty `__init__.py` files) must have a module-level docstring.

### Standard format

```python
"""
myapp.vault - Vault integration for secret management
-----------------------------------------------------

This module provides functions to interact with HashiCorp Vault for secure secret
management. It includes functionality to retrieve and store secrets, handle authentication,
and manage token expiration.

Example::

    from myapp.vault import get_secret, set_secret

    example_secret_value = get_secret("example_secret")
    set_secret("example_secret", "super_secret_value")

Attributes:
    RETRY_COUNT (int): The number of retry attempts for retrieving secrets from Vault.
        Defaults to 10.
    RETRY_INTERVAL (int): The interval in seconds between retry attempts. Defaults to 30.
"""
```

**Rules:**

1. First line: `module.path - short description of what the module does`
2. Second line: dashes (`-`) the same length as the first line
3. Blank line, then one or more description paragraphs
4. Optional `Example::` block (note the double colon — creates a literal code block in Sphinx)
5. Optional `Attributes:` section for module-level constants worth documenting

### Minimal format (acceptable for simple modules)

```python
"""
myapp.data_sources.builds - CI/CD builds data processing
--------------------------------------------------------
"""
```

### Alternative format (acceptable, used in some apps)

```python
"""This module defines the data models for a fleet of virtual machines.

The module includes the following classes:
- ServiceState: Represents the state of a service instance.
- Fleet: Represents a fleet of virtual machines.
"""
```

### `__init__.py` files

Leave empty — no docstring required.

---

## Class Docstrings

Every class needs a docstring. The content depends on the class type.

### General class (with non-trivial constructor)

Document constructor args on the **class** docstring, not on `__init__`:

```python
class ServiceRestClient:
    """REST based client for a remote service.

    Args:
        host (str | None): The base URL of the remote service. If not provided,
            it will be retrieved from the config.
        auth (HTTPBasicAuth | None): Optional authentication method for API
            requests. If not provided, it will be retrieved from the vault.
        cache_enabled (bool | None): Flag to enable or disable caching of API
            responses. Defaults to False.
    """

    def __init__(
        self,
        host: Optional[str] = None,
        auth: Optional[HTTPBasicAuth] = None,
        cache_enabled: Optional[bool] = False,
    ):
        ...
```

### Pydantic `BaseModel` or `@dataclass` — document via `Attributes:`

When fields are declared in the class body (not `__init__`), use `Attributes:` instead of `Args:`:

```python
class Batch(BaseModel):
    """A batch of ItemGroups to be processed together.

    Attributes:
        batch_size (int): The maximum number of item groups allowed in the batch.
        groups (list[ItemGroup]): The list of item groups in the batch.
    """

    batch_size: int
    groups: List[ItemGroup] = []
```

```python
@dataclass(frozen=True)
class User:
    """Represents a user in the application.

    Attributes:
        id (str): Unique identifier for the user.
    """

    id: str = field()
```

### Exception classes

A single one-line docstring is sufficient:

```python
class StorageError(AppException, exceptions.StorageError):
    """Generic exception for errors related to storage operations."""
```

### Abstract base classes

Document the contract, not the implementation:

```python
class ScalingStrategy(ABC):
    """Define the conditions for scaling up and down."""

    @abstractmethod
    def get_requested_change_in_hosts(self, app_state: AppState) -> int:
        """Get the number of hosts to add or remove based on the current state.

        Args:
            app_state (AppState): Current state of the application.

        Returns:
            int: Positive to scale up, negative to scale down, zero for no change.
        """
```

---

## Function and Method Docstrings

### Standard function

```python
def get_secret(secret_name: str, client: Optional[hvac.Client] = None) -> Dict[str, Any]:
    """Retrieves a secret from the secret vault.

    Args:
        secret_name (str): The name of the secret to retrieve.
        client (hvac.Client | None): The HashiCorp Vault client to use. Defaults to None.

    Returns:
        dict[str, Any]: The retrieved secret as a dictionary.

    Raises:
        Exception: If the secret cannot be read from the vault.
    """
```

### Context manager / generator — use `Yields:` instead of `Returns:`

```python
@contextlib.contextmanager
def chdir(path: Union[str, Path]) -> Iterator[Path]:
    """Navigates to the provided path and returns to the original directory afterwards.

    Best used with a `with` statement.

    Args:
        path (str | Path): Path to navigate to.

    Yields:
        Path: The new working directory as a Path object.

    Raises:
        FileNotFoundError: If the specified path does not exist.
        NotADirectoryError: If the specified path is not a directory.
    """
```

### Class method

```python
@classmethod
def merge_batches(cls, batches: Sequence[Batch]) -> Batch:
    """Merge multiple Batch instances into a single Batch.

    Args:
        batches (Sequence[Batch]): Sequence of Batch instances to merge.

    Returns:
        Batch: A new Batch instance containing all groups from the input batches
        and a batch_size equal to the sum of their batch_sizes.

    Raises:
        ValueError: If the input list is empty.
    """
```

### Static method

```python
@staticmethod
def _read_vault_secrets() -> Dict[str, str]:
    """Fetch secrets from Vault.

    Returns:
        dict[str, str]: A dictionary containing all required secrets.

    Raises:
        KeyError: If a required secret path is not found in the vault.
        Exception: For any errors during vault communication.
    """
```

### Properties

Simple properties: one-line docstring only.

```python
@property
def items(self) -> List[Item]:
    """All items contained in the batch."""
    return [item for group in self.groups for item in group.items]
```

Complex properties: include `Returns:` and optionally `Note:`.

```python
@property
def is_authenticated(self) -> bool:
    """All User instances are considered authenticated by design.

    Returns:
        bool: Always returns True.

    Note:
        This property is required by Flask-Login's UserMixin interface.
    """
    return True
```

### Private / internal helpers

Brief one-liner is acceptable. Still use `Args:`/`Returns:` when the function has non-obvious parameters:

```python
def _to_path(path: Union[str, Path]) -> Path:
    """Convert a string path to a Path object if necessary.

    Args:
        path (str | Path): The path to convert.

    Returns:
        Path: The path as a Path object.
    """
    return Path(path) if isinstance(path, str) else path
```

### `__init__` method

Do **not** duplicate the class docstring. Only add `__init__` docstring if there is significant initialization logic worth documenting separately (e.g. validation in `__post_init__`):

```python
def __post_init__(self) -> None:
    """Validate user data after initialization.

    Raises:
        TypeError: If id is not a string.
        ValueError: If id is None.
    """
```

---

## Docstring Section Reference

| Section | Used when | Example |
| ------- | --------- | ------- |
| `Args:` | Function/method has parameters | `secret_name (str): The name of the secret.` |
| `Returns:` | Function returns a non-`None` value | `dict[str, Any]: The retrieved secret.` |
| `Yields:` | Function is a generator or context manager | `Path: The new working directory.` |
| `Raises:` | Function may raise exceptions | `KeyError: If a required key is missing.` |
| `Attributes:` | Class has important attributes (Pydantic/dataclass) | `batch_size (int): Maximum groups.` |
| `Note:` | Important caveat or usage constraint | Required by Flask-Login interface. |
| `Example:` / `Example::` | Usage example in module or class docstring | Double colon creates a literal block. |

### Args/Returns type notation in docstrings

Use the compact **Python 3.10+ style** in docstring text, regardless of the actual annotation style in the code:

| Python typing code | Docstring text |
| ------------------ | -------------- |
| `Optional[str]` | `str \| None` |
| `Union[str, Path]` | `str \| Path` |
| `Dict[str, Any]` | `dict[str, Any]` |
| `List[str]` | `list[str]` |
| `Sequence[ItemGroup]` | `Sequence[ItemGroup]` |
| `Tuple[str, str]` | `tuple[str, str]` |
| `Type[Vault]` | `Type[Vault]` |

---

## Type Hinting

### Imports

Always import from `typing` — do **not** use PEP 585 built-in generics (`dict[...]`, `list[...]`) in actual annotations:

```python
from typing import Any, Dict, Iterator, List, Optional, Sequence, Set, Tuple, Type, Union
```

Use only what you need in each file.

### Forward references and self-referential types

Add `from __future__ import annotations` at the very top (after any encoding declarations, before other imports) when:

- A class method returns its own class type (`-> Batch`)
- Two classes reference each other
- A type annotation references a class defined later in the same file

```python
from __future__ import annotations

from pydantic import BaseModel


class Batch(BaseModel):
    @classmethod
    def merge_batches(cls, batches: Sequence[Batch]) -> Batch:  # Batch used before fully defined
        ...
```

### Annotating function signatures

```python
def clean(
    path: Optional[Union[str, Path]] = None,
    exclude: Optional[Sequence[str]] = None,
) -> None:
    ...
```

```python
def get_client(
    vault_spec: Union[Type[Vault], Tuple[str, str]],
    kv_version: int = 2,
) -> hvac.Client:
    ...
```

### Annotating class attributes

**Pydantic models** and **dataclasses** — annotate directly in the class body:

```python
class Batch(BaseModel):
    batch_size: int
    groups: List[ItemGroup] = []
```

```python
@dataclass
class User:
    id: str = field()
```

**Plain classes** — annotate in `__init__` (no class-body annotation needed):

```python
class ServiceRestClient:
    def __init__(self, host: Optional[str] = None) -> None:
        self._host = host
        self._cache: Dict[str, Any] = {}
```

### Module-level variables

Type-annotate constants and significant module-level variables:

```python
RETRY_COUNT: int = 10
RETRY_INTERVAL: int = 30
_log = logging.getLogger(__name__)   # logger — type inferred, no annotation needed
```

### `None` return type

Always annotate `-> None` on methods/functions that don't return a value, including `__init__` and `__post_init__`:

```python
def __init__(self, secrets: Optional[Dict[str, str]] = None) -> None:
    ...

def start(self) -> None:
    ...
```

### `Optional` vs default `None`

Use `Optional[X]` (not `Union[X, None]`) when a parameter or return value may be absent:

```python
def get_active_cron(self, crt_time: Optional[datetime] = None) -> CronTrigger:
    ...
```

---

## Complete Example

```python
"""
myapp.secrets - Secrets management
----------------------------------

This module provides a central interface for accessing secrets stored in a vault,
encapsulating them in a secure manner, and making them available to other
components of the application.
"""

from dataclasses import dataclass
from typing import Dict, Optional

from pydantic import SecretStr

from myapp.config import AppConfig
from myapp.vault import get_secret


@dataclass
class Secrets:
    """Secure container for application credentials and secrets.

    This class provides an interface to access application secrets, either
    by directly providing them or by fetching them from Vault.
    All secrets are stored using Pydantic's SecretStr to prevent accidental
    exposure in logs or string representations.

    Attributes:
        username (SecretStr): Username for service authentication.
        password (SecretStr): API token for service authentication.
    """

    def __init__(self, secrets: Optional[Dict[str, str]] = None) -> None:
        if secrets is None:
            secrets = self._read_vault_secrets()
        self.username = SecretStr(secrets.get("username", ""))
        self.password = SecretStr(secrets.get("password", ""))

    @staticmethod
    def _read_vault_secrets() -> Dict[str, str]:
        """Fetch secrets from Vault.

        Returns:
            dict[str, str]: A dictionary containing all required secrets.

        Raises:
            KeyError: If a required secret path is not found in the vault.
            Exception: For any errors during vault communication.
        """
        config = AppConfig()
        auth_secret = get_secret("service_auth")
        return {
            "username": auth_secret["username"],
            "password": auth_secret["api_token"],
        }
```
