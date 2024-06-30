param (
    [string]$clientName
)

if (-not $clientName) {
    Write-Host "Usage: .\add-client.ps1 <client-name>"
    exit 1
}

# Генерация ключей клиента
$clientPrivateKey = & 'C:\Program Files\WireGuard\wg.exe' genkey
$clientPublicKey = $clientPrivateKey | & 'C:\Program Files\WireGuard\wg.exe' pubkey

# Создание конфигурации клиента
$clientConfigContent = @"
[Interface]
PrivateKey = $clientPrivateKey
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = $(Get-Content -Path 'C:\Program Files\WireGuard\publickey')
Endpoint = <server_ip>:51820
AllowedIPs = 0.0.0.0/0
"@

$clientConfigContent | Out-File -FilePath "$clientName.conf" -Encoding ascii

# Добавление клиента в конфигурацию сервера
$serverConfigContent = @"
[Peer]
PublicKey = $clientPublicKey
AllowedIPs = 10.0.0.2/32
"@

$serverConfigContent | Add-Content -Path 'C:\Program Files\WireGuard\wg0.conf'

# Перезапуск WireGuard
& 'C:\Program Files\WireGuard\wg.exe' /installtunnelservice "C:\Program Files\WireGuard\wg0.conf"
& 'C:\Program Files\WireGuard\wg.exe' /uninstalltunnelservice "C:\Program Files\WireGuard\wg0.conf"
& 'C:\Program Files\WireGuard\wg.exe' /installtunnelservice "C:\Program Files\WireGuard\wg0.conf"
