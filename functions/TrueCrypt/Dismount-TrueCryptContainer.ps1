<#
$Metadata = @{
	Title = "Dismount TrueCrypt Container"
	Filename = "Dismount-TrueCyptContainer.ps1"
	Description = "Dismount a TrueCrypt container."
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-01-08"
	LastEditDate = "2014-03-03"
	Url = ""
	Version = "0.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Dismount-TrueCyptContainer{

<#
.SYNOPSIS
    Dismount a TrueCrypt container.

.DESCRIPTION
	Dismount a TrueCrypt container which is defined in a PowerShell Profile configuration file.

.PARAMETER Name
	Name or Key of the containers.

.PARAMETER All
	Dismount all containers.
       
.EXAMPLE
	PS C:\> Dismount-TrueCyptContainer
    
.EXAMPLE
	PS C:\> Dismount-TrueCyptContainer -Name "Private Container"
#>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory=$false)]
		[String]
		$Name 
	)
  
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
        
    if(-not (Get-Command TrueCrypt)){
    
        throw ("Command TrueCrypt not available, try `"Install-PPApp TrueCrypt`"")
    }
        
    Get-TrueCryptContainer -Name:$Name -Mounted | %{   
        
        Write-Host "Dismount TrueCrypt container: $($_.Name) on drive: $($_.Drive)" 
        & TrueCrypt /quit /dismount $_.Drive
        Start-Sleep -s 3
        (Get-ChildItem ($_.Path)).lastwritetime = Get-Date

        # update truecrypt data file
        $_ 
        
    } | %{
    
        $TrueCryptContainer = $_
    
        Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.TrueCryptContainer.DataFile -Recurse| %{
    
            $Xml = [xml](get-content $_.Fullname)
            $RemoveNode = Select-Xml $xml -XPath "//Content/MountedContainer[@Name=`"$($TrueCryptContainer.Name)`"]"
            $null = $RemoveNode.Node.ParentNode.RemoveChild($RemoveNode.Node)
            $Xml.Save($_.Fullname)
    
        }
    }
}