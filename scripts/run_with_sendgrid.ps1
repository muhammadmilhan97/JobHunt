Param(
  [switch]$Release
)

# WARNING: This file contains a secret for local development only.
# Do NOT commit or share this file publicly.

$ErrorActionPreference = 'Stop'

$sendGridKey = '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'

if ($Release) {
  flutter build apk --dart-define=SENDGRID_API_KEY=$sendGridKey
} else {
  flutter run --dart-define=SENDGRID_API_KEY=$sendGridKey
}


