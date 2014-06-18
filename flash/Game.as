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
	import flash.system.Capabilities;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
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
		private var lastHit:int = 0;
		private var powerShift:Number = 0, foeShift:Number = 0;
		private var adPending:Boolean = false;
		private var score:Array = [0,0];
		private var myServe:Boolean = true;
		private var serving:Boolean = false;
		private var peerLost:Boolean = false;
		private var waitingForPeer:Boolean = false;
		private var serveTimer:Timer;
		private var recordPending:int = 0;
		
		private var so:SharedObject = SharedObject.getLocal("blinkpong");
		
		private var voice:Voice = Voice.instance;

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
			if(isMultiplayer()) {
				Project.instance.blinkIO.hook = onPeerAction;
			}
			else {
				serveTimer = new Timer(3000,1);
				serveTimer.addEventListener(TimerEvent.TIMER_COMPLETE,foeServe);
			}
			initGame(isMultiplayer());
			if(level==1 && score[0]==0 && score[1]==0 && !isMultiplayer() && so.data.record) {
				bestLevel.visible = true;
				bestLevel.gotoAndStop(so.data.record);
				addChild(bestLevel);
			}
		}
		
		private function get level():int {
			return so.data.level?so.data.level:1;
		}
		
		private function set level(value:int):void {
			so.setProperty("level",value>1?value:null);
		}
		
		private function persistScore():void {
			if(!isMultiplayer()) {
				so.setProperty("score",score);
			}
		}
		
		private function getScore():Array {
			return so.data.score ? so.data.score : [0,0];
		}
		
		private function initGame(resetScore:Boolean):void {
			stage.frameRate = Project.instance.frameRate + Math.max(0,level-10);
			if(!resetScore) {
				score = getScore();
			}
			if(resetScore || (score[0]>=11||score[1]>=11) && diffScore(score)>=2) {
				score = [0,0];
			}
			recordPending = 0;
			myServe = isMultiplayer() ? Project.instance.blinkIO.host :
				int((score[0]+score[0]+1)/2)==0;
			foeShift = powerShift = 0;
			voice.speaking = false;
			paused = false;
			initBall();
			showScore(false,false);
			showLevel();
			speakLevel();
		}
		
		private function isMultiplayer():Boolean {
			return Project.instance.blinkIO!=null;
		}
		
		private function showLevel():void {
			levelMC.gotoAndStop(isMultiplayer()?"VERSUS":Math.min(level,100));
			levelMC.visible = true;
		}
			
		private function hideLevel():void {
			levelMC.visible = false;
		}
		
		private function speakLevel():void {
			if(isMultiplayer()) {
				voice.speakSounds([new PlayerVsPlayerSound()]);
			}
			else {
				speakSounds([voice.voices.level].concat(voice.voiceNumber(level)));
			}
		}
		
		private function initBall():void {
			ball = new Vector3D(0,-8,myServe?0:8);
			bmov = new Vector3D();
			serving = true;
			peerLost = false;
			waitingForPeer = false;
			if(!isMultiplayer() && !myServe) {
				serveTimer.reset();
				serveTimer.delay = 2000+Math.random()*2000;
				serveTimer.start();
			}
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
				var returnBall:Boolean = isMultiplayer() ? !peerLost : 
					Math.random()<.8 + Math.min(.19,.1 * (level)/12);
				
				if(returnBall) {
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
				if(peerLost) {	//	fake a hit back
					paddleSound.play(0,0,sTransform(powerShift/3));
					hitBall(false,false);
					animateShot(false);
				}
				else {
					losePoint();
				}
			}
		}
		
		private function sTransform(shift:Number):SoundTransform {
			ballSoundTransform.volume =  Math.max(0,1-Math.max(0,ball.z)/15 + shift);
			ballSoundTransform.pan = ball.x/20;
			
			//trace(Math.abs(ball.z));
			return ballSoundTransform;
		}
		
		private function hitBall(reverse:Boolean,serve:Boolean):void {
			if(reverse) {
				ball.y = serve?1.5:5;
				ball.z = 10;
				bmov.y = serve?1.5:-3 + 1*Math.sqrt(foeShift);
				bmov.z = serve?-.25:-.3 - .1*foeShift;
				bmov.x = Math.random()-.5-ball.x/20;
			}
			else {
				ball.y = serve?1.5:5;
				ball.z = 0;
				bmov.y = serve?1.5:-3 + 1*Math.sqrt(powerShift);
				bmov.z = serve?.25:.3 + .1*powerShift;
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
			if(getTimer()-lastHit<400 || voice.speaking) {
				noSound.play();
				return;
			}
			lastHit = getTimer();
			if(paused) {
				if(adPending) {
					Project.instance.showAd();
					adPending = false;
				}
				else if(recordPending) {
					if(!newRecord.visible) {
						newRecord.gotoAndStop(recordPending);
						speakSounds([new NewRecordSound(),"level",recordPending]);
						newRecord.visible = true;
						addChild(newRecord);
						recordPending = 0;
					}
				}
				else if(waitingForPeer) {
				}
				else {
					if(getTimer()-pausedTime > 200) {
						paused = false;
						newRecord.visible = false;
						if((score[0]>=11||score[1]>=11) && diffScore(score)>=2) {
							initGame(true);
						}
						else {
							initBall();
						}
						foeShift /= 2;
						powerShift /= 2;
						hideScore();
					}
				}
			}
			else if(ball.z>=-1 && ball.z<3) {
				if(levelMC.visible) {
					hideLevel();
					hideScore();
					bestLevel.visible = false;
				}
				
				if(isMultiplayer() && serving) {
					Project.instance.blinkIO.send("serve");
				}
				
				if(!serving)
					affectShot(Math.abs(ball.z));
				
				paddleSound.play(0,0,sTransform(powerShift/3));
				hitBall(false,serving);
				animateShot(false);
				serving = false;
			}
			else if(ball.z>5) {
				noSound.play();
			}
			else {
				noSound.play();
//				losePoint();
			}
		}
		
		private function diffScore(score:Array):int {
			return Math.abs(score[0]-score[1]);
		}
		
		private function losePoint():void {
			if(isMultiplayer()) {
				Project.instance.blinkIO.send("lost");
				waitingForPeer = true;
			}
			loseSound.play();
			paused = true;
			paintBall();
			score[1]++;
			persistScore();
			showScore(false,true);
			speakScore();
			checkServe();			
			if(score[1]>=11 && diffScore(score)>=2) {
				if(isMultiplayer()) {
					adPending = AdHandler.isSupported;
				}
				else {
					checkRecord(level);					
					level = 1;
					adPending = AdHandler.isSupported;
				}
			}
		}
		
		private function checkRecord(level:int):void {
			var record:int =so.data.record ? so.data.record : 1;
			if(level>record) {
				so.setProperty("record",level);
				recordPending = level;
			}
		}
		
		private function winPoint():void {
			winSound.play();
			paused = true;
			paintBall();
			score[0]++;
			persistScore();
			showScore(true,false);
			speakScore();
			checkServe();
			if(score[0]>=11 && diffScore(score)>=2) {
				if(isMultiplayer()) {
					adPending = AdHandler.isSupported;
				}
				else {
					Gamejolt.postScore(level,score);
					Gamejolt.unlock("8344");
					level++;
					adPending = AdHandler.isSupported;
				}
			}
		}
		
		private function checkServe():void {
			if((score[0]+score[1])%2==1) {
				myServe = !myServe;
			}
		}
		
		private function showScore(win:Boolean,lose:Boolean):void {
			score1.gotoAndStop(score[0]+1+(win?101:0));
			score2.gotoAndStop(score[1]+1+(lose?101:0));
			score1.visible = score2.visible = true;
			gameover.visible = (score[0]>=11||score[1]>=11) && diffScore(score)>=2;
			gameover.gotoAndStop(score[0]>score[1]?1:2);
		}
		
		private function speakScore():void {
			var voicesToSpeak:Array = [voice.voices[score[0]],voice.voices[score[1]]];
			if(score[0]>=11 && diffScore(score)>=2) {
				voicesToSpeak.push(voice.voices.Uwin);
			}
			else if(score[1]>=11 && diffScore(score)>=2) {
				voicesToSpeak.push(voice.voices.Iwin);				
			}
			speakSounds(voicesToSpeak);
		}
		
		private function speakSounds(voices:Array):void {
			voice.speakSounds(voices,
				function():void {
					if(peerLost)
						Project.instance.blinkIO.send("continue");
					if(paused)
						onAction(null);
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
		
		private function foeServe(e:TimerEvent=null):void {
			if(levelMC.visible) {
				hideLevel();
				hideScore();
				bestLevel.visible = false;
			}
			paddleSound.play(0,0,sTransform(foeShift/3));
			serving = false;
			hitBall(true,true);
			animateShot(true);
		}
		
		private function onPeerAction(action:String,...params):void {
			switch(action) {
				case "serve":
					foeServe();
					break;
				case "lost":
					if(waitingForPeer) {
						//	this case happens if both players lost. In that case, we force the serving player to win
						if(myServe) {
							peerLost = true;
							waitingForPeer = false;
							score[1]--;
							winPoint();
						}
					}
					else {
						peerLost = true;
					}
					break;
				case "continue":
					if(waitingForPeer) {
						peerLost = false;	//	peerLost=true is the case when both players lost and we had to force-win the player who serves
						waitingForPeer = false;
						onAction(null);
					}
					break;
			}
		}		
	}
	
}
