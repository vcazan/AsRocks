﻿package  {		import flash.display.Sprite;	import flash.events.ErrorEvent;	import flash.display.MovieClip;	import flash.events.*;			public class content extends MovieClip {				public var pageNum:Number = 1;		public function content() {content1.infotext.species.text = "Sample";content1.infotext.catname.text = "Sample";content1.infotext.acquiredin.text = "Sample";content1.infotext.formula.text = "Sample";content1.infotext.feature.text = "Sample";			page1.addEventListener(MouseEvent.CLICK, page1Function);			page2.addEventListener(MouseEvent.CLICK, page2Function);			page3.addEventListener(MouseEvent.CLICK, page3Function);			addEventListener(Event.ENTER_FRAME,myFunction);  play();}function buttonReset():void {page1.alpha = 0.2;page2.alpha = 0.2;page3.alpha = 0.2;page1.addEventListener(MouseEvent.CLICK, page1Function);page2.addEventListener(MouseEvent.CLICK, page2Function);page3.addEventListener(MouseEvent.CLICK, page3Function);if (pageNum == 1){page1.alpha = 1;page1.removeEventListener(MouseEvent.CLICK, page1Function);} else if (pageNum == 2){page2.alpha = 1;page2.removeEventListener(MouseEvent.CLICK, page2Function);} else {page3.alpha = 1;page3.removeEventListener(MouseEvent.CLICK, page3Function);}}function pageChange():void {play();trace(pageNum + " AND " + currentFrameLabel); if (this.currentFrameLabel == "page1end"){if (pageNum == 1){gotoAndPlay("page1start");} else if (pageNum == 2){gotoAndPlay("page2start");} else if (pageNum == 3){gotoAndPlay("page3start");}} else if (this.currentFrameLabel == "page2stop"){if (pageNum == 1){gotoAndPlay("page1start");} else if (pageNum == 2){gotoAndPlay("page2start");} else if (pageNum == 3){gotoAndPlay("page3start");}} else if (this.currentFrameLabel == "page3stop"){if (pageNum == 1){gotoAndPlay("page1start");} else if (pageNum == 2){gotoAndPlay("page2start");} else if (pageNum == 3){gotoAndPlay("page3start");}}}function myFunction(event:Event) {  }  function page1Function(e:MouseEvent):void{pageNum = 1;buttonReset();pageChange();}function page2Function(e:MouseEvent):void{pageNum = 2;buttonReset();pageChange();}function page3Function(e:MouseEvent):void{pageNum = 3;buttonReset();pageChange();}	}	}