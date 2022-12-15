package scripting;

class HScriptGroup
{
	public var grp:Array<HaxeScript> = [];
	public var globalVars:Map<String, Dynamic> = [];

	public function new(?grp:Array<HaxeScript>)
	{
		if (grp != null)
			this.grp = grp;
	}

	public function add(script:HaxeScript)
	{
		script.parentGrp = this;
		grp.push(script);
	}

	public function updateVars()
	{
		for (i in grp)
			i.updateVars();
	}

	public function callFunction(func:String, ?args:Array<Dynamic>)
	{
		for (i in grp)
			i.callFunction(func, args);
	}
}
