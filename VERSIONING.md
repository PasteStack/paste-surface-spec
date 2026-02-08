# Spec Versioning Strategy

## Version Format

```
MAJOR.MINOR.PATCH
```

- **MAJOR**: Breaking changes to ViewModels, templates, or manifest format
- **MINOR**: New ViewModels, new optional fields, new components
- **PATCH**: Documentation fixes, clarifications

## Compatibility Rules

### Implementations declare spec version

Each implementation (paste-surface-scala, paste-surface-jinja, etc.) declares which spec version it implements:

```scala
// paste-surface-scala
object PasteSurface {
  val SpecVersion = "1.2.0"
}
```

```python
# paste-surface-jinja
SPEC_VERSION = "1.2.0"
```

### Spec changes are additive when possible

**MINOR version bump (1.1.0 → 1.2.0):**
- New optional fields on ViewModels
- New ViewModels
- New components

Implementations on 1.1.0 continue to work. They just don't have the new features.

**MAJOR version bump (1.x → 2.0.0):**
- Renamed fields
- Removed ViewModels
- Changed manifest format
- Changed template paths

## Example: Adding a new field

### Spec change (paste-surface-spec)

```markdown
## PageMeta (v1.2.0)

| Property | Type | Required | Since |
|----------|------|----------|-------|
| siteName | string | yes | 1.0.0 |
| title | string | yes | 1.0.0 |
| description | string | no | 1.0.0 |
| **canonicalUrl** | string | no | **1.2.0** |  ← NEW
```

### Implementation adopts it (paste-surface-scala)

```scala
// v0.5.0 - implements spec 1.1.0
case class PageMeta(
  siteName: String,
  title: String,
  description: Option[String] = None
)

// v0.6.0 - implements spec 1.2.0
case class PageMeta(
  siteName: String,
  title: String,
  description: Option[String] = None,
  canonicalUrl: Option[String] = None  // NEW - optional, backwards compatible
)
```

### Other implementations catch up later

```python
# paste-surface-jinja v0.3.0 - still on spec 1.1.0
# Works fine, just doesn't have canonicalUrl

# paste-surface-jinja v0.4.0 - adopts spec 1.2.0
# Now has canonicalUrl
```

## Deprecation Process

1. **Spec marks as deprecated** (MINOR bump)
   ```markdown
   | Property | Deprecated | Replacement |
   |----------|------------|-------------|
   | seoTitle | 1.3.0 | Use `title` instead |
   ```

2. **Implementations warn** (at their own pace)
   ```scala
   @deprecated("Use title instead", "0.7.0")
   val seoTitle: Option[String] = None
   ```

3. **Spec removes** (MAJOR bump, e.g., 2.0.0)
   ```markdown
   ## Breaking Changes in 2.0.0
   - Removed `seoTitle` from PageMeta (use `title`)
   ```

4. **Implementations remove** (at their own pace)

## Manifest Format Versioning

The manifest includes its own version:

```json
{
  "manifestVersion": "1.0.0",
  "version": "2025.02.02",
  "assets": { ... }
}
```

Runtime libraries check compatibility:

```scala
def load(path: Path): Manifest = {
  val data = parse(path)
  val manifestVersion = data.manifestVersion
  
  if (manifestVersion.major != SupportedManifestVersion.major) {
    throw new IncompatibleManifestException(
      s"Manifest version $manifestVersion not supported. " +
      s"This library supports ${SupportedManifestVersion.major}.x"
    )
  }
  
  // Parse with backwards compatibility for minor versions
  ...
}
```

## Summary

| Change Type | Spec Bump | Implementations |
|-------------|-----------|-----------------|
| New optional field | MINOR | Adopt when ready |
| New ViewModel | MINOR | Adopt when ready |
| Rename field | MAJOR | Must update together |
| Remove field | MAJOR | Must update together |
| New required field | MAJOR | Must update together |
