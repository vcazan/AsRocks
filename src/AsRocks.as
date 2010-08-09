package
{
	import flash.display.*;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.*;
	
	//Calls for the xml file that will get the right info
	// Species: trace(myXML.column.specimen.en.species);
	// Images: trace(myXML.column.specimen.images);
	// Video: trace(myXML.column.specimen.video);
	//Specifit video trace(myXML.column[0].specimen[0].video.flv);
	
	public class AsRocks extends Sprite
	{
		private var myXML:XML;
		private var textArea:MovieClip = new infotext() as MovieClip;	

		public function AsRocks()
		{
			var myLoader:URLLoader = new URLLoader();
			myLoader.load(new URLRequest("../../../Case1/case1.xml"));
			myLoader.addEventListener(Event.COMPLETE, processXML);
			
			addChild(textArea);
			
			function processXML(e:Event):void {
				myXML = new XML(e.target.data);
				dataLoaded();
			}
		}
		
		private function dataLoaded():void{
			var imageURLRequest:URLRequest = new URLRequest("../../../Case1/images/specimens/preview/" + myXML.column[2].specimen[0].images.full); 
			var myImageLoader:Loader = new Loader(); 
			myImageLoader.load(imageURLRequest);
			var x:int;
			for (x=0; x <= 5;x++){
				trace(x);
			textArea.species.text = myXML.column[0].specimen[x].en.species;
			textArea.acquiredin.text = myXML.column[0].specimen[x].en.country;
			textArea.formula.text = myXML.column[0].specimen[x].all.formula;
			textArea.features.text = myXML.column[0].specimen[x].en.feature;
			}
			
			myImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded); 
			function imageLoaded(e:Event):void { 
				   var myBitmapData:BitmapData = new BitmapData(myImageLoader.width, myImageLoader.height); 
				   myBitmapData.draw(myImageLoader); 
				   var myBitmap:Bitmap = new Bitmap; 
				   myBitmap.bitmapData = myBitmapData; 
				
				
				myBitmap.x = 69.95;
				myBitmap.y = 137.40;
				myBitmap.width = 257.15;
				myBitmap.height = 257.15;
				
				   addChild(myBitmap); 
			} 
		}
		
	}
}