BeforeAll {
    # 接続処理はすでに前段で行っているため、再度行わない
    Write-Host "Using existing connection to SharePoint."
    get-pnpcontext
}

# テスト定義
Describe "SPO-Operations モジュールのテスト" {
    Context "正常系" {
        It "should retrieve files from a SharePoint library" {
            $libname = "testlib1"
            try {
                # すでに接続済みの状態でSharePointからファイルを取得
                $result = Get-SpoFiles -siteUrl $siteUrl -libname $libname
                Write-Host "Retrieved Files: $result"
                if ($result.Count -gt 0) {
                    Write-Host "取得したファイル:"
                    foreach ($file in $result) {
                        Write-Host "ファイル名: $($file.FileName), パス: $($file.FilePath)"
                    }
                }
                $result | Should -Not -BeNullOrEmpty -Because "Files should be returned from the SharePoint library"
            } catch {
                Write-Host "エラー: $($_.Exception.Message)"
                throw $_
            }
        }

        It "should retrieve items from a SharePoint list" {
            $listName = "Applist"
            try {
                # すでに接続済みの状態でSharePointからアイテムを取得
                $result = Get-SPOItems -siteUrl $siteUrl -listName $listName -status "approved"
                Write-Host "Retrieved Items: $result"
                if ($result.Count -gt 0) {
                    Write-Host "取得したアイテム:"
                    foreach ($item in $result) {
                        Write-Host "アイテム名: $($item['Title']), ステータス: $($item['Status'])"
                    }
                }
                $result | Should -Not -BeNullOrEmpty -Because "Items should be returned from the SharePoint list"
            } catch {
                Write-Host "エラー: $($_.Exception.Message)"
                throw $_
            }
        }
    }

    Context "異常系" {
        It "should throw an error if the library does not exist" {
            $libname = "NonExistentLibrary"
            try {
                Get-SpoFiles -siteUrl $siteUrl -libname $libname -ErrorAction Stop
                throw "エラー: ライブラリが存在しないはずですが、ファイルを取得できました。"
            } catch {
                $errorMessage = "成功: ライブラリ '$libname' は存在しないため、エラーが発生しました。"
                Write-Host $errorMessage
                if (-not (Test-Path "C:\AIPtest\Logs")) {
                    New-Item -ItemType Directory -Path "C:\AIPtest\Logs"
                }
                $errorMessage | Out-File -FilePath "C:\AIPtest\Logs\error_log.txt" -Append
            }
        }

        It "should throw an error if the list does not exist" {
            $listName = "NonExistentList"
            try {
                Get-SPOItems -siteUrl $siteUrl -listName $listName -status "approved" -ErrorAction Stop
                throw "エラー: リストが存在しないはずですが、アイテムを取得できました。"
            } catch {
                $errorMessage = "成功: リスト '$listName' は存在しないため、エラーが発生しました。"
                Write-Host $errorMessage
                if (-not (Test-Path "C:\AIPtest\Logs")) {
                    New-Item -ItemType Directory -Path "C:\AIPtest\Logs"
                }
                $errorMessage | Out-File -FilePath "C:\AIPtest\Logs\error_log.txt" -Append
            }
        }
    }
}
