# Listing 6 - Registry Test Class
class RegistryTest {
    [string]$operator
	[string]$Value
    # Method to create a blank instance of this class
    RegistryTest(){
    }
    # Method to create an instance of this class populated with data from a generic PowerShell object
    RegistryTest(
        [object]$object
    ){
        $this.operator = $object.operator
		$this.Value = $object.Value
    }
}
