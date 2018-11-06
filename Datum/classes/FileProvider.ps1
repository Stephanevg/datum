Class FileProvider : DatumProvider {
    hidden $Path
    hidden [hashtable] $Store
    hidden [hashtable] $DatumHierarchyDefinition
    hidden [hashtable] $StoreOptions
    hidden [hashtable] $DatumHandlers

    FileProvider ($Path,$Store,$DatumHierarchyDefinition)
    {
        $this.Store = $Store
        $this.DatumHierarchyDefinition = $DatumHierarchyDefinition
        $this.StoreOptions = $Store.StoreOptions
        $this.Path = Get-Item $Path -ErrorAction SilentlyContinue
        $this.DatumHandlers = $DatumHierarchyDefinition.DatumHandlers
        $null = Get-ChildItem $path | ForEach-Object {
            if($_.PSisContainer) {
                $val = [scriptblock]::Create("New-DatumFileProvider -Path `"$($_.FullName)`" -StoreOptions `$this.DataOptions -DatumHierarchyDefinition `$this.DatumHierarchyDefinition")
                $this | Add-Member -MemberType ScriptProperty -Name $_.BaseName -Value $val
            }
            else {
                $itemName = if($_.BaseName -notmatch '\.?Datum') { $_.BaseName} else { $_.BaseName -replace '\.?Datum'}
                $val = [scriptblock]::Create("Get-FileProviderData -Path `"$($_.FullName)`" -DatumHandlers `$this.DatumHandlers")
                $this | Add-Member -MemberType ScriptProperty -Name $itemName -Value $val
            }
        }
    }
}