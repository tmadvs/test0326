BeforeAll {
    # 環境変数から値を取得
    $siteUrl = "https://adstest2025.sharepoint.com"
    $tenantId = $env:TENANT_ID
    $clientId = $env:CLIENT_ID
    $certificatePath = "mycert.pfx"
    $certificatePassword = $env:CERT_PASSWORD

    Write-Host "TENANT_ID: $tenantId"
    Write-Host "CLIENT_ID: $clientId"
    Write-Host "CERT_PASSWORD: $certificatePassword"

    # 接続処理
    try {
        Connect-PnPOnline -Url $siteUrl -Tenant $tenantId -ClientId $clientId -CertificatePath $certificatePath -CertificatePassword (ConvertTo-SecureString -String $certificatePassword -AsPlainText -Force)
        Write-Host "SharePoint Online に接続しました。"
    }
    catch {
        Write-Host "接続エラー: $($_.Exception.Message)"
        throw $_
    }
}
