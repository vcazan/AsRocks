package
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.HUISlider;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.quasimondo.bitmapdata.CameraBitmap;
	
	import flash.display.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	import ru.inspirit.surf.ASSURF;
	import ru.inspirit.surf.IPoint;
	import ru.inspirit.surf.SURFOptions;
	import ru.inspirit.surf_example.FlashSURFExample;
	import ru.inspirit.surf_example.MatchElement;
	import ru.inspirit.surf_example.MatchList;
	import ru.inspirit.surf_example.utils.QuasimondoImageProcessor;
	import ru.inspirit.surf_example.utils.SURFUtils;
	
	//Calls for the xml file that will get the right info
	// Species: trace(myXML.column.specimen.en.species);
	// Images: trace(myXML.column.specimen.images);
	// Video: trace(myXML.column.specimen.video);
	//Specifit video trace(myXML.column[0].specimen[0].video.flv);
	
	public class AsRocks extends FlashSURFExample
	{
		private var myXML:XML;
		private var textArea:MovieClip = new infotext() as MovieClip;	
		private var imageArea:MovieClip = new enlarge() as MovieClip;	
		private var menuArea:MovieClip = new menuBar() as MovieClip;	
		private var menuBar1:Sprite = new Sprite();
		private var fullrez:Sprite = new Sprite();
		private var smallrez:Sprite = new Sprite();
		private var mainScreen:Sprite = new Sprite();
		
		private var c =0;
		private var s =0;
		
		private var rockNum=0;
		
		private var pageNum;
		private var size:String;
		
		public static const SCALE:Number = 1.5;
		public static const INVSCALE:Number = 1 / SCALE;
		
		public static const SCALE_MAT:Matrix = new Matrix(1/SCALE, 0, 0, 1/SCALE, 0, 0);
		public static const ORIGIN:Point = new Point();
		
		public var surf:ASSURF;
		public var surfOptions:SURFOptions;
		public var quasimondoProcessor:QuasimondoImageProcessor;
		public var buffer:BitmapData;
		public var autoCorrect:Boolean = false;
		
		public var matchList:MatchList;

		protected var view:Sprite;
		protected var camera:CameraBitmap;
		protected var overlay:Shape;
		protected var screenBmp:Bitmap;
		protected var matchView:Sprite;
				
		protected var matchName = new Array(4);
		
		protected var caseNum = "1";
		
		protected var oldCase = 1;

		
		public function AsRocks()
		{

			for(var i:int = 0; i < matchName.length; i++) {
				matchName[i] = new Array(9);
			}	
			
			pageNum = 0;
			
			addChild(textArea);
			
			
			addChild(smallrez);
			addChild(imageArea);
			
			addChild(fullrez);
			
			addChild(mainScreen);
			menuBar1.addChild(menuArea);
			addChild(menuBar1);

			mainScreen.graphics.beginFill(0,1);
			mainScreen.graphics.drawRect(0,79.60,2000,2000);

			
			menuArea.page3.addEventListener(MouseEvent.CLICK, page3Click);
			menuArea.refresh.addEventListener(MouseEvent.CLICK, onLoadList);

			imageArea.addEventListener(MouseEvent.CLICK, enlargeButton);
			
			view = new Sprite();
			view.y = 80;
			view.x = 680;
			
			screenBmp = new Bitmap();
			view.addChild(screenBmp);
			
			matchView = new Sprite();
			matchView.x = 640;
			view.addChild(matchView);
			
			overlay = new Shape();
			view.addChild(overlay);

			camera = new CameraBitmap(320, 240, 15, false);
			
			screenBmp.bitmapData = camera.bitmapData;
			
			surfOptions = new SURFOptions(int(320 / SCALE), int(240 / SCALE), 200, 0.003, true, 4, 4, 2);
			surf = new ASSURF(surfOptions);
			
			surf.pointMatchFactor = 5.5;
			surf.pointsThreshold = 0.001 //Numbers have been tested and seem the best for our application
			surf.pointMatchFactor = 0.45;
			
			buffer = new BitmapData(surfOptions.width, surfOptions.height, false, 0x00);
			buffer.lock();
			
			quasimondoProcessor = new QuasimondoImageProcessor(buffer.rect);
			//addChild(view);
			
			matchList = new MatchList(surf);
			
			camera.addEventListener(Event.RENDER, render);

			
		}
		
		private function processXML(e:Event):void {
			
			myXML = new XML(e.target.data);
			loadAll();
			//dataLoadRequest();
		}
		private function loadPage():void{
			
			if (matchList.getMatchId() <= 3){
				
				caseNum = matchList.getMatchId() + 1;
				
				if (caseNum != oldCase){
					
					var myLoader:URLLoader = new URLLoader();
					myLoader.load(new URLRequest("../../../Case"+caseNum+"/Case"+caseNum+".xml"));
					myLoader.addEventListener(Event.COMPLETE, processXML);
					
					trace("../../../Case"+caseNum+"/Case"+caseNum+".xml");

								
				}
				
				
				oldCase = caseNum;

			}
		}
		
		protected function render( e:Event ) : void
		{
			var gfx:Graphics = overlay.graphics;
			
			buffer.draw(camera.bitmapData, SCALE_MAT);
			
			var ipts:Vector.<IPoint> = surf.getInterestPoints(buffer);
			gfx.clear();
			SURFUtils.drawIPoints(gfx, ipts, SCALE);
			
			var matched:Vector.<MatchElement> = matchList.getMatches();
			
			SURFUtils.drawMatchedBitmaps(matched, matchView);
			
			loadPage();

		}

		private function loadAll():void{

			pageNum = 0;

			
			for (var y=0; y<=3;y++){
				for (var x=0;x < myXML.column[y].specimen.length();x++){
					
					loadImage(25 + (x*25),100+(y*25),20,20,"../../../Case"+caseNum+"/images/specimens/preview/" + myXML.column[y].specimen[x].images.full,y,x);
					trace(myXML.column[y].specimen.length());
					s++;
				}
				c++;
				s = 0;
			}
			
			menuArea.page3.alpha = 1;
			menuArea.page1.alpha = 0.22;
			menuArea.page2.alpha = 1;
			
		}

		private function dataLoadRequest():void{
			
			if (s < myXML.column[c].specimen.length()){
			
			loadImage(69.95,137.40,257.15,257.15,"../../../Case"+caseNum+"/images/specimens/preview/" + myXML.column[c].specimen[s].images.full,c,s);

			textArea.species.text = myXML.column[c].specimen[s].en.species;
			
			textArea.acquiredin.text = myXML.column[c].specimen[s].en.province + ", "+ myXML.column[c].specimen[s].en.country;

			textArea.formula.text = myXML.column[c].specimen[s].all.formula;
			textArea.features.text = myXML.column[c].specimen[s].en.feature;
			textArea.catname.text = myXML.column[c].specimen[s].all.catnum;
			}
		}
		private function enlargeButton(event:MouseEvent):void {

			//menuBar1.removeEventListener(MouseEvent.CLICK, nextRock);

			menuArea.page1.alpha = 0.22;
			menuArea.page2.alpha = 1;
			menuArea.page3.alpha = 1;
			
			pageNum = 2;	

			var URL = "../../../Case"+caseNum+"/images/specimens/full_res/" + myXML.column[c].specimen[s].images.full;
			
			loadImage(128,75,768,768,URL,c,s);
			
			fullrez.visible = true;
			smallrez.visible =false;
			imageArea.visible = false;
		}
		private function loadImage(x:int,y:int,width:int,height:int,url:String,c:int,s:int):void
		{
			var imageURLRequest:URLRequest = new URLRequest(url); 
			var myImageLoader:Loader = new Loader(); 

			var myBitmap:Bitmap = new Bitmap; 
			var mySprite:Sprite = new Sprite();
			
			myImageLoader.load(imageURLRequest);

			myImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			
			function imageLoaded(e:Event):void { 
				
				var myBitmapData:BitmapData = new BitmapData(myImageLoader.width, myImageLoader.height); 
				
				myBitmapData.draw(myImageLoader); 
	
				myBitmap.bitmapData = myBitmapData;
				
				mySprite.addChild(myBitmap);
				
				rockNum = (c*8)+s;
				
				trace(c + " " + s);
	
				matchName[c][s] = mySprite;
				
				matchName[c][s].addEventListener(MouseEvent.CLICK, clickMatch);
				
	
				if (pageNum == 1){
					smallrez.addChild(myBitmap);
				}
				if( pageNum == 2){
					fullrez.addChild(myBitmap);
				}
				if( pageNum == 0){
					mainScreen.addChild(matchName[c][s]);
				}
					fullrez.useHandCursor = true;
				
					myBitmap.x = x;
					myBitmap.y = y;
				
					if (width != 0){
						myBitmap.width = width;
						myBitmap.height = height;
					}
					
	
					
			}
		}
		

		private function newRock():void {
			if (s == myXML.column[c].specimen.length()){
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
		private function nextRock(event:MouseEvent):void {
			newRock();
		}
		
		private function page1Click(event:MouseEvent):void {
			page1();
		}
		
		private function page3Click(event:MouseEvent):void {
			menuArea.page3.alpha = 1;
			menuArea.page1.alpha = 0.22;
			menuArea.page2.alpha = 1;
			mainScreen.visible = true;
			smallrez.visible = false;
			imageArea.visible = false;
			
		}
		
		private function page1():void {

			pageNum = 1;
			
			imageArea.gotoAndPlay(1);
			
			trace("Loading: " + c + " " + s);
		
			dataLoadRequest();
		
			fullrez.visible = false;
			smallrez.visible = true;
			imageArea.visible = true;
			mainScreen.visible = false;
		
			menuArea.page1.alpha = 1;
			menuArea.page2.alpha = 0.22;
			menuArea.page3.alpha = 1;

		}
		
		private function clickMatch(event:MouseEvent):void {
			for (var y=0; y<=3;y++){
				
				for (var x=0;x<myXML.column[y].specimen.length();x++){
				if (event.target == matchName[y][x]){
					c = y;
					s = x;
					trace("CLICKED: " + y + " " + x);
					menuArea.page1.addEventListener(MouseEvent.CLICK, page1Click);
					page1();
				}
				}
			}
		}

		protected function onLoadList(e:Event):void 
		{
			SURFUtils.openPointsDataFile(loadPointsDone);
		}
		
		protected function loadPointsDone(data:ByteArray):void 
		{		
			matchList.initListFromByteArray(data);
		}
		
	}
}