package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.utils.getTimer;
	import flash.media.SoundChannel;
	
	
	public class Game extends MovieClip {
		
		private var backLayer:Bitmap = new Bitmap(new BitmapData(32,32,false,0),PixelSnapping.NEVER,false);
		private var tableLayer:Bitmap = new Bitmap(new BitmapData(32,32,true,0),PixelSnapping.NEVER,false);
		private var ballLayer:Bitmap = new Bitmap(new BitmapData(32,32,true,0),PixelSnapping.NEVER,false);
		private var sprite:Sprite = new Sprite();
		private var ballImage:Ball = new Ball();
		private var shadowColor:ColorTransform = new ColorTransform(.2,.2,.2);
		private var ball:Vector3D, bmov:Vector3D;
		private var paddleSound:Sound = new PaddleSound();
		private var tableSound:Sound = new TableSound();
		private var loseSound:Sound = new LoseSound();
		private var winSound:Sound = new WinSound();
//		private var airSound:Sound = new AirSound();
		private var noSound:Sound = new NoSound();
		private var ballSoundTransform:SoundTransform = new SoundTransform();
		private var pausedTime:int = 0;
		private var score:Array = [];
		private var level:int = 1;
		private var lastHit:int = 0;
		private var powerShift:Number = 0, foeShift:Number = 0;
		private var speaking:Boolean = false;
		
		private var voices:Object = {
			Iwin:new aywin_01(),
			Uwin:new youwin_01(),
			level:new leval_01(),
			tin:new tin_01(),
			ty:new ty_01(),
			0:new zero_01(),
			1:new one_01(),
			2:new two_01(),
			3:new three_01(),
			4:new four_01(),
			5:new five_01(),
			6:new six_01(),
			7:new seven_01(),
			8:new eight_01(),
			9:new nain_01(),
			10:new ten_01(),
			11:new ileven_01(),
			12:new twelve_01(),
			13:new thirteen_01(),
			14:new fortin_01(),
			15:new fifteen_01(),
			16:[6,"tin"],
			17:[7,"tin"],
			18:[8,"tin"],
			19:[9,"tin"],
			20:new twenty_01(),
			21:[20,1],
			22:[20,2],
			23:[20,3],
			24:[20,4],
			25:[20,5],
			26:[20,6],
			27:[20,7],
			28:[20,8],
			29:[20,9],
			30:new thirty_01(),
			31:[30,1],
			32:[30,2],
			33:[30,3],
			34:[30,4],
			35:[30,5],
			36:[30,6],
			37:[30,7],
			38:[30,8],
			39:[30,9],
			40:[4,"ty"],
			41:[40,1],
			42:[40,2],
			43:[40,3],
			44:[40,4],
			45:[40,5],
			46:[40,6],
			47:[40,7],
			48:[40,8],
			49:[40,9],
			50:new fifty_01(),
			51:[50,1],
			52:[50,2],
			53:[50,3],
			54:[50,4],
			55:[50,5],
			56:[50,6],
			57:[50,7],
			58:[50,8],
			59:[50,9],
			60:[6,"ty"],
			61:[60,1],
			62:[60,2],
			63:[60,3],
			64:[60,4],
			65:[60,5],
			66:[60,6],
			67:[60,7],
			68:[60,8],
			69:[60,9],
			70:[7,"ty"],
			71:[70,1],
			72:[70,2],
			73:[70,3],
			74:[70,4],
			75:[70,5],
			76:[70,6],
			77:[70,7],
			78:[70,8],
			79:[70,9],
			80:[8,"ty"],
			81:[80,1],
			82:[80,2],
			83:[80,3],
			84:[80,4],
			85:[80,5],
			86:[80,6],
			87:[80,7],
			88:[80,8],
			89:[80,9],
			90:[9,"ty"],
			91:[90,1],
			92:[90,2],
			93:[90,3],
			94:[90,4],
			95:[90,5],
			96:[90,6],
			97:[90,7],
			98:[90,8],
			99:[90,9]
		};
		
		public function Game() {
			addEventListener(Event.ADDED_TO_STAGE,onStage);
			addEventListener(Event.REMOVED_FROM_STAGE,offStage);

			sprite.addChild(backLayer);
			sprite.addChild(tableLayer);
			sprite.addChild(ballLayer);
			
			addChild(sprite);
			addChild(score1);
			addChild(score2);
			addChild(gameover);
			addChild(levelMC);
			sprite.scaleX = sprite.scaleY = 10;
			tableLayer.bitmapData.draw(new Table());
			var blackAlphaColor:uint = 0xFF000000;
			var transparentColor:uint = 0x00000000;
			tableLayer.bitmapData.threshold(tableLayer.bitmapData,tableLayer.bitmapData.rect,new Point(),"<=",blackAlphaColor,transparentColor);
			initGame();

		}
		
		private function initGame():void {
			stage.frameRate = 60 + Math.max(0,level-10);
			score = [0,0];
			foeShift = powerShift = 0;
			speaking = false;
			paused = false;
			initBall();
			hideScore();
			showLevel();
			speakLevel();
		}
		
		private function showLevel():void {
			levelMC.gotoAndStop(level);
			levelMC.visible = true;
		}
			
		private function hideLevel():void {
			levelMC.visible = false;
		}
		
		private function voiceNumber(num:Object):Array {
			if(voices[num] is Sound) {
				return [voices[num]];
			}
			else if(voices[num] is Array) {
				var array:Array = [];
				for(var i:int=0;i<voices[num].length;i++) {
					array = array.concat(voiceNumber(voices[num][i]));
				}
				return array;
			}
			return voiceNumber("Uwin");
		}
		
		private function speakLevel():void {
			speakSounds([voices.level].concat(voiceNumber(level)));
		}
		
		private function initBall():void {
			ball = new Vector3D(0,-8,0);
			bmov = new Vector3D();
		}
		
		private function onStage(e:Event):void {
			Project.instance.addEventListener("action",onAction);
			addEventListener(Event.ENTER_FRAME,onRefresh);
		}
		
		private function offStage(e:Event):void {
			Project.instance.removeEventListener("action",onAction);
			removeEventListener(Event.ENTER_FRAME,onRefresh);
		}
		
		private function paintBall():void {
			ballLayer.bitmapData.fillRect(ballLayer.bitmapData.rect,0);
			if(!paused) {
				var scale:Number = Math.pow(.8,ball.z);
				ballLayer.bitmapData.draw(ballImage,new Matrix(scale*ball.y/12,0,0,.3*scale*ball.y/10,16+scale*ball.x,16+16*scale),shadowColor,null,null,false);
				ballLayer.bitmapData.draw(ballImage,new Matrix(scale,0,0,scale,16+scale*ball.x,16+scale*ball.y),null,null,null,false);
				var blackAlphaColor:uint = 0xFF000000;
				var transparentColor:uint = 0x00000000;
				ballLayer.bitmapData.threshold(ballLayer.bitmapData,ballLayer.bitmapData.rect,new Point(),"<=",blackAlphaColor,transparentColor);
			}
		}
		
		private function onRefresh(e:Event):void {
			if(paused)
				return;
			bmov.y += .3;
			ball.incrementBy(bmov);
			
			paintBall();
			
			if(ball.y>16) {
				bmov.y = -bmov.y;
				ball.y = 16;
				if(bmov.z==0) {
					paddleSound.play(0,0,sTransform(0));
				}
				else {
					tableSound.play(0,0,sTransform(0));
				}
			}
			if(ball.z>10) {
				if(Math.random()<.8 + Math.min(.19,.1 * (level)/12)) {
					paddleSound.play(0,0,sTransform(foeShift/3));
	//				bmov.z = -bmov.z;
	//				ball.z = 10;
					hitBall(true,false);
					animateShot(true);
				}
				else {
					winPoint();
				}
				
			}
			else if(ball.z<-2) {
				losePoint();
			}
		}
		
		private function sTransform(shift:Number):SoundTransform {
			ballSoundTransform.volume =  Math.max(0,1-Math.max(0,ball.z)/20 + shift);
			ballSoundTransform.pan = ball.x/20;
			
			//trace(Math.abs(ball.z));
			return ballSoundTransform;
		}
		
		private function hitBall(reverse:Boolean,serve:Boolean):void {
			if(reverse) {
				ball.y = serve?3:5;
				ball.z = 10;
				bmov.y = serve?2:-3 + 1*Math.sqrt(foeShift);
				bmov.z = serve?-.3:-.3 - .1*foeShift;
				bmov.x = Math.random()-.5-ball.x/20;
			}
			else {
				ball.y = serve?3:5;
				ball.z = 0;
				bmov.y = serve?2:-3 + 1*Math.sqrt(powerShift);
				bmov.z = serve?.3:.3 + .1*powerShift;
				bmov.x = Math.random()-.5-ball.x/20;
			}
			
			//	y = at^2 + mt + c = at^2 + c
			//	sqrt(y-cy)/a = t
			//	z = mt + c
			//	(z-cz) / m = t
			//	sqrt(y-cy) = (z-cz) / m
			//	m = (z-cz) / sqrt(y-cy)
//			ball.y = Math.max(5,ball.y);
//			var dest:Vector3D = new Vector3D(0,0,9);
//			bmov.y = 0;
//			bmov.z = (dest.z-ball.z) / Math.sqrt(Math.abs(dest.y-ball.y))/10;
//			trace(bmov.z);
//			bmov.z = .3;
//			dest.z - ball.z;
			
			
//			bmov.z = .3;//Math.min(1,Math.abs(bmov.z) +.01);
//			bmov.y -= .5;
		}
		
		private function affectShot(accuracy:Number):void {
			if(accuracy<.1) {
				powerShift = Math.min(3,powerShift+1);
				foeShift = Math.max(0,foeShift-1);
			}
			else if(accuracy<.2) {
				powerShift = Math.min(3,powerShift+.5);
				foeShift = Math.max(0,foeShift-.5);
			}
			else if(accuracy<.5) {
				powerShift = Math.min(3,powerShift+.2);
				foeShift = Math.max(0,foeShift-.2);
			}
			else {
				foeShift = Math.min(3,foeShift+.1*level);
			}
//			trace(accuracy);
		}
		
		private function onAction(e:Event):void {
			if(getTimer()-lastHit<400 || speaking) {
				noSound.play();
				return;
			}
			lastHit = getTimer();
			if(paused) {
				if(getTimer()-pausedTime > 200) {
					paused = false;
					if(score[0]==11||score[1]==11) {
						initGame();
					}
					else {
						initBall();
					}
					foeShift /= 2;
					powerShift /= 2;
					hideScore();
				}
			}
			else if(ball.z>=-1 && ball.z<3) {
				if(levelMC.visible) {
					hideLevel();
				}
				
				if(bmov.z!=0)
					affectShot(Math.abs(ball.z));
				
				paddleSound.play(0,0,sTransform(powerShift/3));
				hitBall(false,bmov.z==0);
				animateShot(false);
			}
			else if(ball.z>5) {
				noSound.play();
			}
			else {
				losePoint();
			}
		}
		
		private function losePoint():void {
			loseSound.play();
			paused = true;
			paintBall();
			score[1]++;
			showScore(false,true);
			speakScore();
			if(score[1]==11) {
				level = 1;
			}
		}
		
		private function winPoint():void {
			winSound.play();
			paused = true;
			paintBall();
			score[0]++;
			showScore(true,false);
			speakScore();
			if(score[0]==11) {
				
				Gamejolt.postScore(level,score);
				Gamejolt.unlock("8344");
				level++;
			}
		}
		
		private function showScore(win:Boolean,lose:Boolean):void {
			score1.gotoAndStop(score[0]+1+(win?12:0));
			score2.gotoAndStop(score[1]+1+(lose?12:0));
			score1.visible = score2.visible = true;
			gameover.visible = score[0]==11||score[1]==11;
			gameover.gotoAndStop(score[0]==11?1:2);
		}
		
		private function speakScore():void {
			var voicesToSpeak:Array = [voices[score[0]],voices[score[1]]];
			if(score[0]==11) {
				voicesToSpeak.push(voices.Uwin);
			}
			else if(score[1]==11) {
				voicesToSpeak.push(voices.Iwin);				
			}
			speakSounds(voicesToSpeak);
		}
		
		private function speakSounds(sounds:Array):void {
			var sndChannel:SoundChannel = sounds[0].play();
			speaking = true;
			sndChannel.addEventListener(Event.SOUND_COMPLETE,
				function(e:Event):void {
					if(sounds.length>1) {
						speakSounds(sounds.slice(1));
					}
					else {
						speaking = false;
						if(paused)
							onAction(null);
					}
				});
		}
		
		private function hideScore():void {
			score1.visible = score2.visible = false;
			gameover.visible = false;
		}
		
		private function get paused():Boolean {
			return pausedTime!=0;
		}

		private function set paused(value:Boolean):void {
			pausedTime = value?getTimer():0;
		}
		
		private function animateShot(reverse:Boolean):void {
			var dsize:Number = 3;
			var ipos:Number = 16;
			var speed:Number = .8;
			var array:Array = [];
			while(ipos>=1) {
				array.push({ipos:ipos,dsize:dsize});
				ipos *= speed;
				dsize *= speed;
			}
			if(!reverse) {
				array.reverse();
			}
			
			var outerRect:Rectangle = new Rectangle();
			var innerRect:Rectangle = new Rectangle();
			backLayer.bitmapData.fillRect(innerRect,reverse?0:0xFFFFFF);
			addEventListener(Event.ENTER_FRAME,
				function(e:Event):void {
					if(array.length) {
						var obj:Object = array.pop();
						outerRect.left = outerRect.top = Math.round(16-obj.ipos);
						outerRect.right = outerRect.bottom = Math.round(16+obj.ipos);
						
						innerRect.left = innerRect.top = Math.round(outerRect.left+obj.dsize);
						innerRect.right = innerRect.bottom = Math.round(outerRect.right-obj.dsize);
						backLayer.bitmapData.fillRect(backLayer.bitmapData.rect,0);
						backLayer.bitmapData.fillRect(outerRect,0xFFFFFF);
						backLayer.bitmapData.fillRect(innerRect,0);	
					}
					else {
						backLayer.bitmapData.fillRect(backLayer.bitmapData.rect,0);
						e.currentTarget.removeEventListener(e.type,arguments.callee);
					}
				});
		}
	}
	
}
