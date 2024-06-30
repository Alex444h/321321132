# Установка Chocolatey, если он не установлен
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Установка WireGuard
choco install wireguard -y

# Генерация ключей
$privateKey = & 'C:\Program Files\WireGuard\wg.exe' genkey
$publicKey = $privateKey | & 'C:\Program Files\WireGuard\wg.exe' pubkey

# Создание конфигурации для сервера
$configContent = @"
[Interface]
PrivateKey = $privateKey
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <client_public_key>
AllowedIPs = 10.0.0.2/32
"@

$configContent | Out-File -FilePath 'C:\Program Files\WireGuard\wg0.conf' -Encoding ascii

# Включение пересылки IP
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' -Name 'IPEnableRouter' -Value 1

# Настройка правил брандмауэра (Windows Firewall)
netsh advfirewall firewall add rule name="WireGuard" dir=in action=allow protocol=UDP localport=51820
