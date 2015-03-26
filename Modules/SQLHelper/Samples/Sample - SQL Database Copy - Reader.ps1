cls

Import-Module SQLHelper -Force

$sourceConnStr = "Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=AdventureWorksDW2012;Data Source=.\sql2014"

$destinationConnStr = "Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=DestinationDB;Data Source=.\sql2014"

$tables = @("[dbo].[DimProduct]")

$tables = @(
	@{ Name = "DimProduct"; SourceSQL = "select ProductKey, [EnglishProductName] from [dbo].[DimProduct]"; DestinationTable = "[dbo].[DimProduct]"}	
)

$steps = $tables.Count
$i = 1;

$tables |% {
		
	$table = $_	
	
	Write-Progress -activity "Tables Copy" -CurrentOperation "Executing source query over '$sourceTableName'" -PercentComplete (($i / $steps)  * 100) -Verbose
	
	$reader = Invoke-SQLCommand -executeType "Reader" -connectionString $sourceConnStr -commandText $table.SourceSQL -Verbose				
				
	Invoke-SQLBulkCopy -connectionString $destinationConnStr -data @{reader = $reader} -tableName $table.DestinationTable -recreateTable -Verbose
	
	$reader.Dispose()	
					
	$i++;
}

Write-Progress -activity "Tables Copy" -Completed
