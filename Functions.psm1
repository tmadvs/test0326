# 関数やオブジェクトを宣言するファイル

# SharePoint からファイル情報を取得する関数
function Get-SpoFiles {
    param (
        [string]$siteUrl,
        [string]$libname
    )
    
    if (-not $siteUrl) {
        throw "Error: Site URL is null or empty."
    }
    if (-not $libname) {
        throw "Error: Library name is null or empty."
    }

    Write-Host "Getting files from SharePoint site: $siteUrl, Library: $libname"
    
    try {
        $files = Get-PnPListItem -List $libname
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
    
    if (-not $siteUrl) {
        throw "Error: Site URL is null or empty."
    }
    if (-not $listName) {
        throw "Error: List name is null or empty."
    }
    
    try {
        $query = "<View><Query><Where><Eq><FieldRef Name='Status' /><Value Type='Text'>$status</Value></Eq></Where></Query></View>"
        $items = Get-PnPListItem -List $listName -Query $query
        return $items
    } catch {
        Write-Host "エラー: リスト '$listName' からアイテムを取得できません。詳細: $_"
        throw "リスト '$listName' からアイテムを取得できません"
    }
}
