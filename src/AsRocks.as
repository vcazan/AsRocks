﻿package
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
		private var imageArea:MovieClip = new enlarge() as MovieClip;	
		private var menuArea:MovieClip = new menuBar() as MovieClip;	
		private var menuBar1:Sprite = new Sprite();
		private var fullrez:Sprite = new Sprite();
		private var smallrez:Sprite = new Sprite();

		
		private var c =0;
		private var s =0;
		
		private var pageNum;
		private var size:String;
		

		public function AsRocks()
		{
			var myLoader:URLLoader = new URLLoader();
			myLoader.load(new URLRequest("../../../Case1/case1.xml"));
			myLoader.addEventListener(Event.COMPLETE, processXML);
			
			pageNum = 1;
			menuArea.page1.addEventListener(MouseEvent.CLICK, page1);
			menuBar1.addEventListener(MouseEvent.CLICK, nextRock);
			fullrez.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			fullrez.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

			
			addChild(textArea);
			addChild(smallrez);

			addChild(fullrez);
			addChild(menuBar1);
			addChild(imageArea);
			
			menuBar1.addChild(menuArea);
			function processXML(e:Event):void {
				myXML = new XML(e.target.data);
				dataLoadRequest();
			}
			imageArea.addEventListener(MouseEvent.CLICK, enlargeButton);

		}
		
		private function dataLoadRequest():void{
			
			loadImage(69.95,137.40,257.15,257.15,"../../../Case1/images/specimens/preview/" + myXML.column[c].specimen[s].images.full);

			textArea.species.text = myXML.column[c].specimen[s].en.species;
			textArea.acquiredin.text = myXML.column[c].specimen[s].en.country;
			textArea.formula.text = myXML.column[c].specimen[s].all.formula;
			textArea.features.text = myXML.column[c].specimen[s].en.feature;
			textArea.catname.text = myXML.column[c].specimen[s].all.catnum;
		}
		private function enlargeButton(event:MouseEvent):void {
			removeChild(imageArea);
			menuBar1.removeEventListener(MouseEvent.CLICK, nextRock);
			
			removeChild(smallrez);
			
			menuArea.page1.alpha = 0.22;
			menuArea.page2.alpha = 1;
			
			pageNum = 2;
			

			var URL = "../../../Case1/images/specimens/full_res/" + myXML.column[c].specimen[s].images.full;
			loadImage((stage.width-768)/2,0,768,768,URL);
			fullrez.visible = true;
		}
		private function loadImage(x:int,y:int,width:int,height:int,url:String):void
		{
			var imageURLRequest:URLRequest = new URLRequest(url); 
			var myImageLoader:Loader = new Loader(); 
			myImageLoader.load(imageURLRequest);
			myImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			
			trace(pageNum + "    " + size);

			function imageLoaded(e:Event):void { 
			var myBitmapData:BitmapData = new BitmapData(myImageLoader.width, myImageLoader.height); 
			myBitmapData.draw(myImageLoader); 
			var myBitmap:Bitmap = new Bitmap; 
			myBitmap.bitmapData = myBitmapData; 
			
			if (pageNum == 1){
				smallrez.addChild(myBitmap);
			}else{
				fullrez.addChild(myBitmap);
			}
			
			myBitmap.x = x;
			myBitmap.y = y;
				if (width != 0){
					myBitmap.width = width;
					myBitmap.height = height;
				}
			}
		}
		

		private function nextRock(event:MouseEvent):void {
			if (s == 8){
				c++;
				if (c == 4){
					c =0;	
				}
				s=0;	
			}
			s++

			dataLoadRequest();
			
			imageArea.gotoAndPlay(1);
			
			trace("Specimin: " + s + " Column: " + c);
		}
		private function page1(event:MouseEvent):void {

			if (pageNum == 2 || pageNum == 3){
				fullrez.visible = false;

				addChild(smallrez);
				addChild(imageArea);

				menuArea.page1.alpha = 1;
				menuArea.page2.alpha = 0.22;
				
				pageNum = 1;
			}

		}

		private function mouseDownHandler(event:MouseEvent):void {
			fullrez.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			fullrez.startDrag();
		}
		private function mouseMoveHandler(event:MouseEvent):void {
			event.updateAfterEvent();
		}
		private function mouseUpHandler(event:MouseEvent):void {
			fullrez.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			fullrez.stopDrag();
		}
		
	}
}