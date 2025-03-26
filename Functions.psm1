# 関数やオブジェクトを宣言するファイル

# SharePoint からファイル情報を取得する関数
function Get-SpoFiles {
    param (
        [string]$siteUrl,
        [string]$libname
    )
    
    Write-Host "Getting files from SharePoint site: $siteUrl, Library: $libname"
    
    # SharePoint Online からファイルリストを取得
    try {
        $files = Get-PnPListItem -List $libname
        # ファイルが取得できた場合
        if ($files.Count -gt 0) {
            Write-Host "取得したファイル数: $($files.Count)"
            foreach ($file in $files) {
                Write-Host "ファイル名: $($file['FileLeafRef']), パス: $($file['FileDirRef'])"
            }
        } else {
            Write-Host "ライブラリ '$libname' にファイルが見つかりませんでした。"
        }
    }
    catch {
        Write-Host "エラー: ライブラリ '$libname' が存在しないか、アクセスできません。詳細: $_"
        throw "ライブラリ '$libname' が存在しないか、アクセスできません"
    }

    $fileInfo = @()
    
    foreach ($item in $files) {
        $fileInfo += [PSCustomObject]@{
            FileName = $item["FileLeafRef"]
            FilePath = $item["FileDirRef"]
        }
    }
    
    return $fileInfo
}

# SharePoint リストからアイテムを取得する関数（指定したStatusをフィルタリング）
function Get-SPOItems {
    param (
        [string]$siteUrl,
        [string]$listName,
        [string]$status
    )
    
    # SharePoint Online からアイテムを取得（Status列が指定した値のアイテム）
    try {
        $query = "<View><Query><Where><Eq><FieldRef Name='Status' /><Value Type='Text'>$status</Value></Eq></Where></Query></View>"
        $items = Get-PnPListItem -List $listName -Query $query
        # アイテムが取得できた場合
        if ($items.Count -gt 0) {
            Write-Host "取得したアイテム数: $($items.Count)"
            foreach ($item in $items) {
                Write-Host "アイテム名: $($item['Title']), ステータス: $($item['Status'])"
            }
        } else {
            Write-Host "リスト '$listName' にステータス '$status' のアイテムが見つかりませんでした。"
        }
    }
    catch {
        Write-Host "エラー: リスト '$listName' が存在しないか、アクセスできません。詳細: $_"
        throw "リスト '$listName' が存在しないか、アクセスできません"
    }

    return $items
}

# 必要な関数をエクスポート
Export-ModuleMember -Function Get-SpoFiles, Get-SPOItems
