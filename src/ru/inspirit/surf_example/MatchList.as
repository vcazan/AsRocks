package ru.inspirit.surf_example 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.display.MovieClip;
	
	
	import ru.inspirit.surf.ASSURF;
	import ru.inspirit.surf.IPointMatch;
	import ru.inspirit.surf.SURFOptions;
	
	/**
	 * Match list manager
	 * 
	 * @author Eugene Zatepyakin
	 */
	
	
	public final class MatchList 
	{
		public static const POINT_SIZE:int = 69 << 3;
		
		public static var MATCH_THRESHOLD:int = 4;
		public static var DEFAUL_OPTIONS:SURFOptions = new SURFOptions(640, 480, 200, 0.004, true, 3, 5, 5);
		
		public var surf:ASSURF;
		
		public var pointsMap:Vector.<int>;
		public var elements:Vector.<MatchElement>;
		public var elementsCount:int;
		public var pointsCount:int;
		
		public var matchBundle:ByteArray;
		public var writeBundleToMemory:Boolean;
		
		public var matchId:int;
		public var matches:int;
		
		public function MatchList(surf:ASSURF)
		{
			this.surf = surf;

			elementsCount = pointsCount = 0;
			elements = new Vector.<MatchElement>();
			pointsMap = new Vector.<int>();
			matchBundle = new ByteArray();
			
			writeBundleToMemory = true;
		}
		
		public function getMatches():Vector.<MatchElement>
		{			
			var i:int, ind:int = -1, n:int;
			var el:MatchElement;
			var matched:Vector.<MatchElement> = new Vector.<MatchElement>();
			matchId = 666; ///666 Will mean that there is no file currently selected with points data
			
			if(elementsCount == 0) return matched;
			else matchId = 999; //gets switched to 999 once we have a file loaded but no matches are on the screen
			
			n = elementsCount;
			
			
			for( i = 0; i < n; ++i ) elements[i].matchCount = 0;
			
			var matchedPoints:Vector.<IPointMatch> = surf.getMatchesToPointsData(pointsCount, matchBundle, writeBundleToMemory);
			n = matchedPoints.length;
			
			for( i = 0; i < n; ++i )
			{
				elements[pointsMap[ matchedPoints[i].refID ]].matchCount++;
			}
			
			n = elementsCount;
			
			for( i = 0; i < n; ++i )
			{
				el = elements[i];
				
				if(el.matchCount >= MATCH_THRESHOLD) 
				{
					matchId = i;
					matches = el.matchCount;
					matched[++ind] = el;
				}
			}
			
			writeBundleToMemory = false;
			
			return matched;
		}
		public function matchCount():int
		{
			return elementsCount;
		}
		public function getMatchId():int
		{
			return matchId;
		}
		public function addBitmapAsMatch(bitmap:BitmapData, surfOptions:SURFOptions = null):void
		{
			if(surfOptions)
			{
				surf.changeSurfOptions(surfOptions);
			} 
			else 
			{
				DEFAUL_OPTIONS.width = bitmap.width;
				DEFAUL_OPTIONS.height = bitmap.height;
				surf.changeSurfOptions(DEFAUL_OPTIONS);
			}
			
			var ba:ByteArray = new ByteArray();
			var cnt:int = surf.getInterestPointsByteArray(bitmap, ba);
			
			ba.position = 0;
			matchBundle.position = pointsCount * POINT_SIZE;
			matchBundle.writeBytes(ba);
			
			var el:MatchElement = new MatchElement();
			el.pointsCount = cnt;
			el.id = elementsCount;
			el.bitmap = bitmap;
			
			for(var i:int = 0; i < cnt; ++i) 
			{
				pointsMap.push(elementsCount);
			}
			
			elements[elementsCount++] = el;
			
			pointsCount += cnt;
			
			writeBundleToMemory = true;
		}

		public function addRegionAsMatch(rect:Rectangle, bitmap:BitmapData = null):void
		{
			var ba:ByteArray = new ByteArray();
			
			var cnt:int = surf.getInterestPointsRegionByteArray(rect, ba);
			
			if(cnt < MATCH_THRESHOLD) return; // bad idea to search it
			
			ba.position = 0;
			matchBundle.position = pointsCount * POINT_SIZE;
			matchBundle.writeBytes(ba);
			
			var el:MatchElement = new MatchElement();
			el.pointsCount = cnt;
			el.id = elementsCount;
			el.bitmap = bitmap;
			
			for(var i:int = 0; i < cnt; ++i) 
			{
				pointsMap.push(elementsCount);
			}
			
			elements[elementsCount++] = el;
			
			pointsCount += cnt;
			
			writeBundleToMemory = true;
		}
		
		public function clear():void 
		{
			pointsCount = elementsCount = 0;
			pointsMap = new Vector.<int>();
			elements = new Vector.<MatchElement>();
			
			matchBundle.clear();
			writeBundleToMemory = true;
		}

		public function initListFromByteArray(data:ByteArray):void
		{
			data.uncompress();
			data.position = 0;
			
			elementsCount = data.readInt();
			
			pointsMap = new Vector.<int>();
			elements = new Vector.<MatchElement>();
			matchBundle.clear();
			pointsCount = 0;
			
			var j:int, cnt:int;
			var n:int = elementsCount;
			var el:MatchElement;
			
			for(var i:int = 0; i < n; ++i)
			{
				cnt = data.readInt();
				for( j = pointsCount; j < pointsCount+cnt; ++j )
				{
					pointsMap[j] = i;
				}
				
				el = new MatchElement();
				el.id = i;
				el.pointsCount = cnt;
				
				el.bitmap = new BitmapData(data.readInt(), data.readInt(), false, 0x00);
				el.bitmap.setPixels(el.bitmap.rect, data);
				
				elements[i] = el;
				
				pointsCount += cnt;
			}
			matchBundle.writeBytes(data, data.position, pointsCount * POINT_SIZE);
			
			surf.writePointsDataToReference(pointsCount, matchBundle);
			trace("Loaded File");

			writeBundleToMemory = false;
		}
		
		/**
		 * This method saves not only points information but also bitmap data
		 */
		public function saveListToByteArray():ByteArray
		{
			var n:int = elementsCount;
			var ba:ByteArray = new ByteArray();
			var el:MatchElement;
			
			ba.writeInt(n);

			for(var i:int = 0; i < n; ++i)
			{
				el = elements[i];
				ba.writeInt(el.pointsCount);
				ba.writeInt(el.bitmap.width);
				ba.writeInt(el.bitmap.height);
				ba.writeBytes(el.bitmap.getPixels(el.bitmap.rect));
			}
			
			ba.writeBytes(matchBundle);
			ba.compress();
			
			return ba;
		}
	}
}
