Param(
    $SetNumber
)
function Get-LegoSetId {
  <#
  .SYNOPSIS
  Describe the function here
  .DESCRIPTION
  Describe the function in more detail
  .EXAMPLE
  Give an example of how to use it
  .EXAMPLE
  Give another example of how to use it
  .PARAMETER computername
  The computer name to query. Just one.
  .PARAMETER logname
  The name of a file to write failed computer names to. Defaults to errors.txt.
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$True)]
    [string]$SetNumber,

    [string]$apiKey
  )

  begin {}

  process {

    
    $url = "https://brickset.com/api/v2.asmx/getSets?apiKey=$apiKey&userHash=&query=&theme=&subtheme=&setNumber=$SetNumber-1&year=&owned=&wanted=&orderBy=&pageSize=&pageNumber=&userName="

    [xml]$sets = Invoke-WebRequest -Uri $url -Method Get

    foreach ($set in $sets.ArrayOfSets.sets) {
      $info = @{
        'setid'=$set.setid
      }
      Write-Output (New-Object –Typename PSObject –Prop $info)
    }
  }

  end {}
}

function Get-LegoSet {
  <#
  .SYNOPSIS
  Describe the function here
  .DESCRIPTION
  Describe the function in more detail
  .EXAMPLE
  Give an example of how to use it
  .EXAMPLE
  Give another example of how to use it
  .PARAMETER computername
  The computer name to query. Just one.
  .PARAMETER logname
  The name of a file to write failed computer names to. Defaults to errors.txt.
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True)]
    [string]$setid,
		
    [string]$apiKey
  )

  begin {}

  process {

    $url = "https://brickset.com/api/v2.asmx/getSet?apiKey=$apiKey&userHash=&SetID=$setid"
    [xml]$sets = Invoke-WebRequest -Uri $url -Method Get

    foreach ($set in $sets.ArrayOfSets.sets) {
      $set.description = $set.description -replace '["]','`"'
      $set.notes = $set.notes -replace '["]','`"'
      if($set.year -eq '') {$set.year = '????'}
      if($set.theme -eq '') {$set.theme = ' '}
      if($set.subtheme -eq '') {$set.subtheme = ' '}
      if($set.themeGroup -eq '') {$set.themeGroup = ' '}
      if($set.pieces -eq '') {$set.pieces = '?'}
      if($set.minifigs -eq '') {$set.minifigs = '0'}
      if($set.USRetailPrice -eq '') {$set.USRetailPrice = '??.??'}
      if($set.USDateAddedToSAH -eq '') {$set.USDateAddedToSAH = '?'}
      if($set.USDateRemovedFromSAH -eq '') {$set.USDateRemovedFromSAH = '?'}
      if($set.ageMin -eq '') {$set.ageMin = '?'}
      if($set.ageMax -eq '') {$set.ageMax = '?'}
      if($set.notes -eq '') {$set.notes = ' '}
      $info = @{
        'setID'=$set.setID;
        'number'=$set.number;
        'name'=$set.name;
        'year'=$set.year;
        'theme'=$set.theme;
        'themeGroup'=$set.themeGroup;
        'subtheme'=$set.subtheme;
        'pieces'=$set.pieces;
        'minifigs'=$set.minifigs;
        'USRetailPrice'=$set.USRetailPrice;
        'USDateAddedToSAH'=$set.USDateAddedToSAH;
        'USDateRemovedFromSAH'=$set.USDateRemovedFromSAH;
        'packagingType'=$set.packagingType;
        'availability'=$set.availability;
        'ageMin'=$set.ageMin;
        'ageMax'=$set.ageMax;
        'height'=$set.height;
        'width'=$set.width;
        'depth'=$set.depth;
        'weight'=$set.weight;
        'category'=$set.category;
        'notes' = $set.notes;
        'description'=$set.description;
        'imageURL'=$set.imageURL
      }
      Write-Output (New-Object –Typename PSObject –Prop $info)
    }
  }

  end {}
}

function Write-PlasterParameter{
<#
.SYNOPSIS
A simple helper function to create a parameter xml block for plaster
.DESCRIPTION
A simple helper function to create a parameter xml block for plaster.  This function
is best used with an array of hashtables for rapid creation of a Plaster parameter
block.
.PARAMETER ParameterName
The plaster element name
.PARAMETER ParameterType
The type of plater parameter. Can be either text, choice, multichoice, user-fullname, or user-email
.PARAMETER ParameterPrompt
The prompt to be displayed
.PARAMETER Default
The default setting for this parameter
.PARAMETER Store
Specifies the store type of the value. Can be text or encrypted. If not defined then the default is text.
.PARAMETER Choices
An array of hashtables with each hash being a choice containing the lable, help, and value for the choice.
.PARAMETER Obj
Hashtable object containing all the parameters required for this function.
.EXAMPLE
$choice1 = @{
    label = '&yes'
    help = 'Process this'
    value = 'true'
}
$choice2 = @{
    label = '&no'
    help = 'Do NOT Process this'
    value = 'false'
}
Write-PlasterParameter -ParameterName 'Editor' -ParameterType 'choice' -ParameterPrompt 'Choose your editor' -Default '0' -Store 'text' -Choices @($choice1,$choice2)
.EXAMPLE
$MyParams = @(
@{
    ParameterName = "NugetAPIKey"
    ParameterType = "text"
    ParameterPrompt = "Enter a PowerShell Gallery (aka Nuget) API key. Without this you will not be able to upload your module to the Gallery"
    Default = ' '
},
@{
    ParameterName = "OptionAnalyzeCode"
    ParameterType = "choice"
    ParameterPrompt = "Use PSScriptAnalyzer in the module build process (Recommended for Gallery uploading)?"
    Default = "0"
    Store = "text"
    Choices = @(
        @{
            Label = "&Yes"
            Help = "Enable script analysis"
            Value = "True"
        },
        @{
            Label = "&No"
            Help = "Disable script analysis"
            Value = "False"
        }
    )
}) | Write-PlasterParameter
#>

    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(ParameterSetName = "default", Mandatory = $true, Position = 0)]
        [Alias('Name')]
        [string]$ParameterName,

        [Parameter(ParameterSetName = "default", Position = 1)]
        [ValidateSet('text', 'choice', 'multichoice', 'user-fullname', 'user-email')]
        [Alias('Type')]
        [string]$ParameterType = 'text',

        [Parameter(ParameterSetName = "default", Mandatory = $true, Position = 2)]
        [Alias('Prompt')]
        [ValidateNotNullOrEmpty()]
        [string]$ParameterPrompt,

        [Parameter(ParameterSetName = "default", Position = 3)]
        [Alias('Default')]
        [string]$ParameterDefault,

        [Parameter(ParameterSetName = "default", Position = 4)]
        [ValidateSet('text', 'encrypted')]
        [AllowNull()]
        [string]$Store,

        [Parameter(ParameterSetName = "default", Position = 5)]
        [Hashtable[]]$Choices,

        [Parameter(ParameterSetName = "pipeline", ValueFromPipeLine = $true, Position = 0)]
        [Hashtable]$Obj
    )

    process {
        # If a hash is passed then recall this function with the hash splatted instead.
        if ($null -ne $Obj) {
            return Write-PlasterParameter @Obj
        }

        # Create a new XML File with config root node
        $oXMLRoot = New-Object System.XML.XMLDocument

        if (($Type -eq 'choice') -and ($Choices.Count -le 1)) {
            throw 'You cannot setup a parameter of type "choice" without supplying an array of applicable choices to select from...'
        }

        # New Node
        $oXMLParameter = $oXMLRoot.CreateElement("parameter")

        # Append as child to an existing node
        $Null = $oXMLRoot.appendChild($oXMLParameter)

        # Add a Attributes
        $oXMLParameter.SetAttribute("name", $ParameterName)
        $oXMLParameter.SetAttribute("type", $ParameterType)
        $oXMLParameter.SetAttribute("prompt", $ParameterPrompt)
        if (-not [string]::IsNullOrEmpty($ParameterDefault)) {
            $oXMLParameter.SetAttribute("default", $ParameterDefault)
        }
        if (-not [string]::IsNullOrEmpty($Store)) {
            $oXMLParameter.SetAttribute("store", $Store)
        }
        if ($ParameterType -match 'choice|multichoice') {
            if ($Choices.count -lt 1) {
                Write-Warning 'The parameter type was choice/multichoice but there are less than 2 choices. Returning nothing.'
                return
            }
            foreach ($Choice in $Choices) {
                [System.XML.XMLElement]$oXMLChoice = $oXMLRoot.CreateElement("choice")
                $oXMLChoice.SetAttribute("label", $Choice['Label'])
                $oXMLChoice.SetAttribute("help", $Choice['help'])
                $oXMLChoice.SetAttribute("value", $Choice['value'])
                $null = $oXMLRoot['parameter'].appendChild($oXMLChoice)
            }
        }

        $oXMLRoot.InnerXML
    }
}

$setinfo = Get-LegoSetId -SetNumber $SetNumber | Get-LegoSet

$MyParams = @(
@{
    ParameterName = "number"
    ParameterType = "text"
    ParameterPrompt = "number"
    Default = $setinfo.number
},
@{
    ParameterName = "name"
    ParameterType = "text"
    ParameterPrompt = "name"
    Default = $setinfo.name
},
@{
    ParameterName = "year"
    ParameterType = "text"
    ParameterPrompt = "year"
    Default = $setinfo.year
},
@{
    ParameterName = "themeGroup"
    ParameterType = "text"
    ParameterPrompt = "themeGroup"
    Default = $setinfo.themeGroup
},
@{
    ParameterName = "theme"
    ParameterType = "text"
    ParameterPrompt = "theme"
    Default = $setinfo.theme
},
@{
    ParameterName = "subtheme"
    ParameterType = "text"
    ParameterPrompt = "subtheme"
    Default = $setinfo.subtheme
},
@{
    ParameterName = "pieces"
    ParameterType = "text"
    ParameterPrompt = "pieces"
    Default = $setinfo.pieces
},
@{
    ParameterName = "minifigs"
    ParameterType = "text"
    ParameterPrompt = "minifigs"
    Default = $setinfo.minifigs
},
@{
    ParameterName = "USRetailPrice"
    ParameterType = "text"
    ParameterPrompt = "USRetailPrice"
    Default = $setinfo.USRetailPrice
},
@{
    ParameterName = "availability"
    ParameterType = "text"
    ParameterPrompt = "availability"
    Default = $setinfo.availability
},
@{
    ParameterName = "ageMin"
    ParameterType = "text"
    ParameterPrompt = "ageMin"
    Default = $setinfo.ageMin
},
@{
    ParameterName = "ageMax"
    ParameterType = "text"
    ParameterPrompt = "ageMax"
    Default = $setinfo.ageMax
},
@{
    ParameterName = "USDateAddedToSAH"
    ParameterType = "text"
    ParameterPrompt = "USDateAddedToSAH"
    Default = $setinfo.USDateAddedToSAH
},
@{
    ParameterName = "USDateRemovedFromSAH"
    ParameterType = "text"
    ParameterPrompt = "USDateRemovedFromSAH"
    Default = $setinfo.USDateRemovedFromSAH
},
@{
    ParameterName = "notes"
    ParameterType = "text"
    ParameterPrompt = "notes"
    Default = $setinfo.notes
},
@{
    ParameterName = "description"
    ParameterType = "text"
    ParameterPrompt = "description"
    Default = $setinfo.description
},
@{
    ParameterName = "imageURL"
    ParameterType = "text"
    ParameterPrompt = "imageURL"
    Default = $setinfo.imageURL
}) | Write-PlasterParameter

$PlasterManifest = $(Get-Content -Path .\snip1.xml) + $MyParams + $(Get-Content -Path .\snip2.xml)
Set-Content -Value $PlasterManifest -Path .\PlasterManifest.xml -Encoding UTF8

Invoke-Plaster -TemplatePath .\ -DestinationPath .\ -Verbose

ii ".\$($SetNumber).html"

ii ".\$($SetNumber)small.html"
