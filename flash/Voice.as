package  {
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.media.Sound;
	
	public class Voice {

		static public const instance:Voice = new Voice();
		public var speaking:Boolean = false;
		private var soundChannel:SoundChannel = null;
		
		public var voices:Object = {
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

		public function voiceNumber(num:Object):Array {
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
		

		public function speakSounds(sounds:Array,callback:Function=null,cancelPrevious:Boolean=false):void {
			if(cancelPrevious) {
				if(soundChannel) {
					soundChannel.stop();
				}
			}
			while(sounds[0] is Array) {
				sounds = sounds[0].concat(sounds.slice(1));
			}
			if(!(sounds[0] is Sound)) {
				sounds[0] = voices[sounds[0]] || voices[0];
			}
			soundChannel = sounds[0].play();
			speaking = true;
			soundChannel.addEventListener(Event.SOUND_COMPLETE,
				function(e:Event):void {
					if(sounds.length>1) {
						speakSounds(sounds.slice(1),callback,cancelPrevious);
					}
					else {
						speaking = false;
						if(callback!=null) {
							callback();
						}
					}
				});
		}
	}
	
}
