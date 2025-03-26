name: PowerShell CI

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: windows-latest  # Windows環境で実行

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Install PnP.PowerShell Version 1.7.0
        run: |
          Install-Module -Name PnP.PowerShell -Force -Scope CurrentUser -RequiredVersion 1.7.0

      - name: Decode certificate from GitHub Secrets and save as .pfx
        run: |
          # GitHub Secrets から証明書をデコードして .pfx ファイルとして保存
          $certBase64 = "${{ secrets.CERT_PFX }}"
          $certPassword = ConvertTo-SecureString "${{ secrets.CERT_PASSWORD }}" -AsPlainText -Force
          [System.IO.File]::WriteAllBytes("mycert.pfx", [Convert]::FromBase64String($certBase64))

      - name: Connect to SharePoint Online using Certificate
        run: |
          $siteUrl = "https://adstest2025.sharepoint.com"
          $tenantId = "${{ secrets.TENANT_ID }}"
          $clientId = "${{ secrets.CLIENT_ID }}"
          $certificatePath = "mycert.pfx"
          $certificatePassword = "${{ secrets.CERT_PASSWORD }}"

          # 証明書を使用して PnP PowerShell で接続
          Connect-PnPOnline -Url $siteUrl -Tenant $tenantId -ClientId $clientId -CertificatePath $certificatePath -CertificatePassword (ConvertTo-SecureString -String $certificatePassword -AsPlainText -Force)

        env:
          TENANT_ID: ${{ secrets.TENANT_ID }}
          CLIENT_ID: ${{ secrets.CLIENT_ID }}
          CERT_PASSWORD: ${{ secrets.CERT_PASSWORD }}

      - name: Install Pester
        run: |
          Install-Module -Name Pester -Force -SkipPublisherCheck

      - name: Run Pester Tests
        run: |
          $config = New-PesterConfiguration
          $config.Run.Path = "./Functions.Tests.ps1"
          $config.CodeCoverage.Enabled = $true
          $config.CodeCoverage.OutputFormat = "JaCoCo"
          $config.CodeCoverage.OutputPath = "./coverage.xml"
          Invoke-Pester -Configuration $config

      - name: Install Codecov CLI
        run: |
          Invoke-WebRequest -Uri https://uploader.codecov.io/latest/windows/codecov.exe -OutFile codecov.exe

      - name: Upload coverage report to Codecov
        run: |
          .\codecov.exe -t ${{ secrets.CODECOV_TOKEN }} -f './coverage.xml' -r tmadvs/test0326
        env:
          CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
