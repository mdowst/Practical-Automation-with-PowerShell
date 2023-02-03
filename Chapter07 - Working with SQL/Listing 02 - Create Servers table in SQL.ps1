# Listing 2 - Create Servers table in SQL
$SqlInstance = "$($env:COMPUTERNAME)\SQLEXPRESS"
$DatabaseName = 'PoshAssetMgmt'
$ServersTable = 'Servers'
$ServersColumns = @(
    # Create the ID column as an identity column 
    @{Name = 'ID';            
        Type = 'int'; MaxLength = $null; 
        Nullable = $false; Identity = $true; 
    }
    # Create the Name column as a string with a max length of 50 characters
    @{Name = 'Name';         
        Type = 'nvarchar'; MaxLength = 50;    
        Nullable = $false; Identity = $false; 
    }
    # Create the OSType column as a string with a max length of 15 characters
    @{Name = 'OSType';         
        Type = 'nvarchar'; MaxLength = 15;    
        Nullable = $false; Identity = $false; 
    }
    # Create the OSVersion column as a string with a max length of 50 characters
    @{Name = 'OSVersion';         
        Type = 'nvarchar'; MaxLength = 50;    
        Nullable = $false; Identity = $false; 
    }
    # Create the a Status column as a string with a max length of 15 characters
    @{Name = 'Status';   
        Type = 'nvarchar'; MaxLength = 15; 
        Nullable = $false; Identity = $false; 
    }
    # Create the RemoteMethod column as a string with a max length of 25 characters
    @{Name = 'RemoteMethod';         
        Type = 'nvarchar'; MaxLength = 25;    
        Nullable = $false; Identity = $false; 
    }
    # Create the UUID column as a string with a max length of 255 characters
    @{Name = 'UUID';         
        Type = 'nvarchar'; MaxLength = 255;    
        Nullable = $false; Identity = $false; 
    }
    # Create the Source column as a string with a max length of 15 characters
    @{Name = 'Source';         
        Type = 'nvarchar'; MaxLength = 15;    
        Nullable = $false; Identity = $false; 
    }
    # Create the SourceInstance column as a string with a max length of 255 characters
    @{Name = 'SourceInstance';         
        Type = 'nvarchar'; MaxLength = 255;    
        Nullable = $false; Identity = $false; 
    }
)
$DbaDbTable = @{
    SqlInstance = $SqlInstance
    Database    = $DatabaseName
    Name        = $ServersTable
    ColumnMap   = $ServersColumns
}
New-DbaDbTable @DbaDbTable