package
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.*;
	
	
	
	
	//Calls for the xml file that will get the right info
	// Species: trace(myXML.column.specimen.en.species);
	// Images: trace(myXML.column.specimen.images);
	// Video: trace(myXML.column.specimen.video);
	
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
				trace(myXML.column.specimen.video);
			}	
		}
	}
}