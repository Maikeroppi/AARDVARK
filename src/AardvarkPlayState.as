package  
{
	import org.flixel.*;
	
	import org.flixel.FlxObject;
		
	/**
	 * ...
	 * @author Maikeroppi
	 */
	public class AardvarkPlayState extends FlxState 
	{
		// Images
		[Embed(source = "data/bg.png")] private var ImgBackground:Class;
		[Embed(source = "data/python.png")] private var ImgPython:Class;
		[Embed(source = "data/aardvark.png")] private var ImgAardvark:Class;
		[Embed(source = "data/adore64.ttf", fontFamily = "NES", embedAsCFF = "false")] 	public	var	FontAdore64:String;
		
		// Sound effects
		[Embed(source = "data/Death.mp3")] private var DeathSound:Class;
		[Embed(source = "data/Jump.mp3")] private var JumpSound:Class;
		[Embed(source = "data/PythonArrives.mp3")] private var PythonSound:Class;
		[Embed(source = "data/Dig.mp3")] private var DigSound:Class;
		
		// Background Constants
		public const BGScrollSpeed:Number 			= 4;
		public const BGWidth:Number					= 320;
		public const BGHeight:Number				= 240;
		
		// Python Constants
		public const PythonStartY 		:Number		= GroundY;
		public const PythonStartX		:Number 	= BGWidth + 20;
		public const PythonMaxVelocity	:Number		= 250;
		public const PythonMaxAccelY	:Number		= 200;
		
		// Timer Constants
		public const StartingEnemySpawnTimer:Number = 1.5;
		public const EnemySpawnLevelRatio:Number	= 0.95;
		
		// Ground Constants
		public const UnderGroundY		:Number		= 220;
		public const GroundY			:Number		= 150;
		
		// Player Constants
		public const PlayerStartX:Number 			= 20;
		public const PlayerStartY:Number 			= 90;
		public const PlayerMaxAccelX:Number			= 0;
		public const PlayerMaxAccelY:Number			= 200;
		public const PlayerMaxVelocity:Number		= 350;
		public const PlayerMinY:Number				= 40;
		public const PlayerMaxY:Number				= 160;
			
		// Construct our game
		public var BG1_:FlxTileblock;
		public var BG2_:FlxTileblock;
		public var Player_:FlxSprite;
		public var Ground_:FlxTileblock;
		public var UnderGround_:FlxTileblock;
		public var Python_:FlxSprite;
		public var PythonActive_:Boolean;
		public var GameOver_:Boolean;
		public var PlayerUnderground_:Boolean;
		public var TitleText_:FlxText;
		public var StatusText_:FlxText;

		// For use as timers
		public var PlayerSolidTimer_:Number;
		public var LastSpawnEnemyTimer_:Number;
		public var SpawnEnemyTimer_:Number;
		
		
		// Metagroups for collision
		public var SpriteGroup_:FlxGroup;
		public var GroundGroup_:FlxGroup;
				
		override public function create():void
		{
			// Create the background, which doubles as the level as well.
			BG1_ = new FlxTileblock(0, 0, BGWidth, BGHeight);
			BG1_.loadGraphic(ImgBackground);
			add(BG1_);
			
			BG2_ = new FlxTileblock(BGWidth, 0, BGWidth, BGHeight);
			BG2_.loadGraphic(ImgBackground);
			add(BG2_);
			
			// Initialize some text
			TitleText_ = new FlxText(BGWidth / 2, 0, 100, "AARDVARK");
			TitleText_.setFormat("NES", 8, 0xffffff, "center");
			TitleText_.scrollFactor.x = TitleText_.scrollFactor.y = 0;
			// Center at the top
			TitleText_.x = (BGWidth / 2) - (TitleText_.width / 2);
			add(TitleText_);
			
			StatusText_ = new FlxText(0, TitleText_.height, BGWidth, "AARDVARK HAS DIED");
			StatusText_.setFormat("NES", 8, 0xffffff, "center");
			StatusText_.scrollFactor.x = StatusText_.scrollFactor.y = 0;
			StatusText_.visible = false;
			add(StatusText_);
			
			// Construct blocks for the Aardvark to stand on.			
			Ground_ = new FlxTileblock(0, GroundY, 320, GroundY+1);
			Ground_.allowCollisions = FlxObject.UP;
			add(Ground_);
			
			UnderGround_ = new FlxTileblock(0, UnderGroundY, 320, UnderGroundY+1);
			UnderGround_.allowCollisions = FlxObject.UP | FlxObject.DOWN | FlxObject.LEFT | FlxObject.RIGHT;
			add(UnderGround_);
			
			// Initialize our main objects, the Python and player.
			Python_ = new FlxSprite(PythonStartX, PythonStartY, ImgPython);
			Python_.width = Python_.width - 20;
			Python_.height = Python_.height - 20;
			Python_.offset.y = 20;
			Python_.offset.x = 20;
			Python_.maxVelocity.y = PythonMaxVelocity;
			Python_.maxVelocity.x = PythonMaxVelocity;
			Python_.velocity.x = 0;
			Python_.acceleration.y = PythonMaxAccelY;
			Python_.visible = false;
			PythonActive_ = false;
			
			add(Python_);
			
			Player_ = new FlxSprite(PlayerStartX, PlayerStartY, ImgAardvark);
			
			// Create our player
			Player_.loadGraphic(ImgAardvark, true, false, 100, 60);
			Player_.maxVelocity.y = PlayerMaxVelocity;
			Player_.drag.x = Player_.maxVelocity.x * 4;
			Player_.acceleration.y = PlayerMaxAccelY;
			
			// Note: These are for the bounding box
			Player_.width = Player_.width - 30;
			//Player_.height = Player_.height - 20;
			Player_.offset.x = 15;
			//Player_.offset.y = 5;
			
			// Setup player "animations", currently just single frames
			Player_.addAnimation("Run", [0], 10, true);
			Player_.addAnimation("Die", [1], 10, true);
					
			
			// Allow for jumping from underground to above ground.
			Player_.allowCollisions = FlxObject.LEFT 
				| FlxObject.RIGHT 
				| FlxObject.DOWN;
			add(Player_);
			PlayerUnderground_ = false;
			
			// Create our metagroups
			SpriteGroup_ = new FlxGroup();
			SpriteGroup_.add(Player_);
			SpriteGroup_.add(Python_);
			GroundGroup_ = new FlxGroup();
			GroundGroup_.add(Ground_);
			GroundGroup_.add(UnderGround_);

			// Set up timers
			SpawnEnemyTimer_ = StartingEnemySpawnTimer;
			LastSpawnEnemyTimer_ = StartingEnemySpawnTimer;
			PlayerSolidTimer_ = 0;
			
			// Set GameOver to false
			GameOver_ = false;
			FlxG.camera.stopFX();
			FlxG.flash(0xff000000,0.5);
		}
		
		override public function update():void
		{
			var RandNum:Number;
			
			
			FlxG.collide(SpriteGroup_, GroundGroup_);

			
			// Scroll the background
			BG1_.x = BG1_.x - BGScrollSpeed;
			BG2_.x = BG2_.x - BGScrollSpeed;
			Python_.update();
			
			// Handle timers
			if (PlayerSolidTimer_ > 0) {
				PlayerSolidTimer_ -= FlxG.elapsed;
			} else {
				PlayerSolidTimer_ = 0;
				Player_.solid = true;
			}
			
			if(PythonActive_ == false) {
				// Check the enemy "spawn" timer
				if (SpawnEnemyTimer_ > 0) {
					SpawnEnemyTimer_ -= FlxG.elapsed;				
				} else {
					RandNum = Math.random() * 2;
					
					// Time to reset our python
					Python_.x = PythonStartX;
					
					// Randomize above/below ground
					Python_.y = (RandNum > 1)? GroundY -80: UnderGroundY -80;
					
					Python_.velocity.x = -PythonMaxVelocity / 2;
					Python_.visible = true;
					PythonActive_ = true;
					FlxG.play(PythonSound);
				}
			} else {
				// Python off the screen; time to deactivate
				if (Python_.x <= -100) {
					Python_.visible = false;
					Python_.velocity.x = 0;					
					PythonActive_ = false;
					
					// Decrease the time in which we spawn pythons
					SpawnEnemyTimer_ = LastSpawnEnemyTimer_ * EnemySpawnLevelRatio;
					LastSpawnEnemyTimer_ = SpawnEnemyTimer_;
				}
			}
				
			// If backgrounds have scrolled too far, reset them for our infinite scrolling
			if (BG1_.x <= -320) BG1_.x = 320;
			if (BG2_.x <= -320) BG2_.x = 320;
			
			
			//Handle player input
			if (Player_.isTouching(FlxObject.FLOOR) ) {
				if (FlxG.keys.UP) {
					Player_.velocity.y = -Player_.maxVelocity.y / 2;
					PlayerUnderground_ = false;
					FlxG.play(JumpSound);
				} else if (FlxG.keys.DOWN && !PlayerUnderground_) {
					Player_.solid = false;
					PlayerSolidTimer_ = 0.2;
					PlayerUnderground_ = true;
					FlxG.play(DigSound);
				}
			}
			
			// Player hit a python, oops!
			if (FlxG.collide(Player_, Python_)) {
				FlxG.play(DeathSound);
				Player_.velocity.y = 0;
				Player_.velocity.x = 0;
				Player_.acceleration.x = 0;
				Player_.y = Player_.y -10;
				
				Python_.velocity.x = 0;
				Python_.acceleration.x = 0;
				
				Player_.play("Die", true);			
				
				GameOver_ = true;
				StatusText_.visible = true;
				FlxG.fade(0xff000000, 0.5, create);
			}
			
			super.update();
		}	
	}
	
	

}