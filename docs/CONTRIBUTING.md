# Contributing Guide

Thank you for considering contributing to the PDF Translation App!

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Submit a pull request

## Development Setup

See [SETUP.md](./SETUP.md) for detailed setup instructions.

## Code Style

### Python (Backend)

- Follow PEP 8 style guide
- Use type hints
- Maximum line length: 100 characters
- Use docstrings for functions and classes

```python
def translate_text(text: str, target_lang: str = "ja") -> str:
    """
    Translate text to target language.

    Args:
        text: Text to translate
        target_lang: Target language code

    Returns:
        Translated text
    """
    pass
```

### TypeScript/JavaScript (Frontend)

- Use TypeScript for type safety
- Follow Airbnb style guide
- Use functional components
- Use hooks for state management

```typescript
interface TranslationProps {
  documentId: string;
  onComplete?: (result: Translation) => void;
}

const TranslationComponent: React.FC<TranslationProps> = ({
  documentId,
  onComplete
}) => {
  // Component implementation
};
```

### Swift (iOS)

- Follow Swift API Design Guidelines
- Use SwiftLint for linting
- Prefer structs over classes when possible
- Use meaningful variable names

```swift
struct DocumentService {
    func uploadDocument(_ url: URL) async throws -> DocumentResponse {
        // Implementation
    }
}
```

## Testing

### Backend Tests

```bash
cd backend
pytest
pytest --cov=app tests/  # With coverage
```

### Frontend Tests

```bash
cd frontend
npm test
npm run test:coverage  # With coverage
```

### iOS Tests

```bash
cd ios/PDFTranslator
xcodebuild test -scheme PDFTranslator
```

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(backend): add batch translation endpoint
fix(frontend): resolve PDF upload error handling
docs(api): update translation endpoint documentation
```

## Pull Request Process

1. Update documentation if needed
2. Add tests for new features
3. Ensure all tests pass
4. Update CHANGELOG.md
5. Request review from maintainers

## Reporting Bugs

Use GitHub Issues and include:

1. Description of the bug
2. Steps to reproduce
3. Expected behavior
4. Actual behavior
5. Environment details (OS, versions, etc.)
6. Screenshots if applicable

## Feature Requests

Submit feature requests as GitHub Issues:

1. Clear description of the feature
2. Use cases
3. Potential implementation approach
4. Any relevant examples

## Questions?

Open a GitHub Discussion or reach out to the maintainers.
