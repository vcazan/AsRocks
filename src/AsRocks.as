package
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.*;
	
	public class AsRocks extends Sprite
	{
		public function AsRocks()
		{
			var myXML:XML;
			var myLoader:URLLoader = new URLLoader();
			myLoader.load(new URLRequest("../casedata/case1.xml"));
			myLoader.addEventListener(Event.COMPLETE, processXML);
			
			function processXML(e:Event):void {
				myXML = new XML(e.target.data);
				trace(myXML.column[2].@id);
			}	
		}
	}
}