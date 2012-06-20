package 
{
	import org.flixel.*;
	[SWF(width = "640", height = "480", backgroundColor = "#000000")]
	
	/**
	 * ...
	 * @author Maikeroppi
	 */
	public class Main extends FlxGame 
	{
		
		public function Main():void 
		{
			super(320, 240, AardvarkPlayState, 2);
			//forceDebugger = true;
			//FlxG.debug = true;
			//FlxG.visualDebug = true;
		}
		
		
		
	}
	
}