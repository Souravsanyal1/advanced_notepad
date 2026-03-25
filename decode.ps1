$inputFile = "android/app/upload-keystore.jks"
$outputFile = "android/app/upload-keystore_binary.jks"
$base64 = Get-Content $inputFile -Raw
$bytes = [Convert]::FromBase64String($base64)
[IO.File]::WriteAllBytes($outputFile, $bytes)
