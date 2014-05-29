using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace BlinkPong
{
	public class Player : BasePlayer {
        public void addGame(String gameId,String type,String author,int slots,int numPlayers,Action<DatabaseObject> callback)
        {
            if (!PlayerObject.Contains("games"))
            {
                PlayerObject.Set("games", new DatabaseObject());
            }
            DatabaseObject games = PlayerObject.GetObject("games");
            if (!games.Contains(gameId))
            {
                DatabaseObject game = new DatabaseObject();
                game.Set("gameId",gameId);
                game.Set("type", type);
                game.Set("author", author);
                game.Set("slots", slots);
                game.Set("numPlayers", numPlayers);
                games.Set(gameId, true);
            }
            PlayerObject.Save();
            callback(PlayerObject);
        }

        public String name
        {
            get { 
                return PlayerObject.GetString("name",null);
            }
            set { 
                PlayerObject.Set("name",value);
                PlayerObject.Save();
            }
        }


        public byte[] profilePicture
        {
            get
            {
                return PlayerObject.GetBytes("profilePicture",null);
            }

            set
            {
                PlayerObject.Set("profilePictureAlignment", new DatabaseArray {0,0});
                PlayerObject.Set("profilePicture", value);
                PlayerObject.Save();
            }
        }

        public DatabaseArray profilePictureAlignment
        {
            get
            {
                return PlayerObject.GetArray("profilePictureAlignment");
            }

            set
            {
                PlayerObject.Set("profilePictureAlignment", value);
                PlayerObject.Save();
            }
        }
	}

    [RoomType("BlinkPong")]
	public class GameCode : Game<Player> {

        private uint tick = 0;

		public override void GameStarted() {
            PreloadPlayerObjects = true;
            AddTimer(delegate
            {
                Broadcast("tick",tick++);
            }, 100);

        }

        public override void UserJoined(Player player)
        {
            base.UserJoined(player);

            //  Set player name
            if (player.JoinData.ContainsKey("name") && player.name != player.JoinData["name"])
            {
                player.name = player.JoinData["name"];
            }

            long lastJoined = player.PlayerObject.Contains("lastJoined") ? player.PlayerObject.GetDateTime("lastJoined").Ticks : 0;


            player.PlayerObject.Set("lastJoined", new DateTime());
            player.PlayerObject.Save();
            Broadcast("joined",player.ConnectUserId,this.PlayerCount);
            BroadcastLeaderboard(player);

            Message playerNames = Message.Create("player");
            foreach (Player p in Players)
            {
                if (p.name != null)
                {
                    playerNames.Add(p.ConnectUserId);
                    playerNames.Add("name");
                    playerNames.Add(p.name);
                }
                if (p.profilePicture != null)
                {
                    playerNames.Add(p.ConnectUserId);
                    playerNames.Add("profilePicture");
                    playerNames.Add(p.profilePicture);

                    playerNames.Add(p.ConnectUserId);
                    playerNames.Add("profilePictureAlignment");
                    playerNames.Add(p.profilePictureAlignment[0],p.profilePictureAlignment[1]);
                }
            }
            if (playerNames.Count > 0)
            {
                player.Send(playerNames);
            }

            PlayerIO.BigDB.LoadRange("Chat", "date", null, null, null, 200,
                delegate (DatabaseObject[] array) {
                    if (array.Length>0)
                    {
                        Message message = Message.Create("send");
                        message.Add(true);
                        for(int i=array.Length-1;i>=0;i--) {
                            DatabaseObject data = array[i];
                            String objectId = data.GetString("objectId");
                            String action = data.GetString("action");
                            byte[] bytes = data.GetBytes("params");
                            message.Add(objectId);
                            message.Add(action);
                            message.Add(bytes);
                        }
                        player.Send(message);
                        if(array.Length>100)
                            PlayerIO.BigDB.DeleteRange("Chat", "date", null, array[array.Length / 2].GetDateTime("date"), null, null);
                    }
                });
        }

        private void BroadcastLeaderboard(Player player=null,int rankFor=0,Action<int> rankCallback=null) 
        {
            PlayerIO.BigDB.LoadRange("Leaderboard", "score", null, null, null, rankCallback != null ? 1000 : 10,
                delegate(DatabaseObject[] array)
                {
                    if (array.Length > 0)
                    {
                        Message message = Message.Create("leaderboard");
                        int maxcount = 10, rank = 1;
                        foreach (DatabaseObject data in array)
                        {
                            String name = data.GetString("name");
                            int score = data.GetInt("score");
                            byte[] bytes = data.GetBytes("data");
                            if (message.Count < maxcount * 2) {
                                message.Add(name);
                                message.Add(score);
                                if (bytes != null)
                                {
                                    message.Add(bytes);
                                }
                            }
                            if (rankCallback != null && rankFor < score)
                            {
                                rank++;
                            }
                        }
                        if (rankCallback!=null)
                        {
                            rankCallback(rank);
                        }
                        if (player != null)
                            player.Send(message);
                        else
                            Broadcast(message);
                    }
                });
        }

        public override void UserLeft(Player player)
        {
            base.UserLeft(player);
            Broadcast("left", player.ConnectUserId, this.PlayerCount);
        }

        private void handleScore(Player player,Message message)
        {
            DatabaseObject obj = new DatabaseObject();
            String name = message.GetString(0);
            int score = message.GetInteger(1);
            byte[] bytes = message.GetByteArray(2);
            PlayerIO.BigDB.LoadOrCreate("Leaderboard", name,
                delegate(DatabaseObject databaseObject)
                {
                    int bestScore;
                    Boolean updateScore = !databaseObject.Contains("score") || databaseObject.GetInt("score") < score;
                    if (updateScore)
                    {
                        bestScore = score;
                        databaseObject.Set("name", name);
                        databaseObject.Set("score", score);
                        if (bytes != null)
                        {
                            databaseObject.Set("data", bytes);
                        }
                        databaseObject.Save(
                            delegate
                            {
                                BroadcastLeaderboard(null, bestScore,
                                    delegate(int rank)
                                    {
                                        player.Send("rank", rank);
                                    });
                            });
                    }
                    else
                    {
                        bestScore = databaseObject.GetInt("score");
                        BroadcastLeaderboard(null, bestScore,
                            delegate(int rank)
                            {
                                player.Send("rank", rank);
                            });
                    }
                });
        }

        private void handleMessage(Message message) {

            Broadcast(message);

            Boolean persist = message.GetBoolean(0);
            if (persist)
            {
                String objectId = message.GetString(1);
                String action = message.GetString(2);
                byte[] bytes = message.GetByteArray(3);
                DatabaseObject obj = new DatabaseObject();
                obj.Set("objectId", objectId);
                obj.Set("action", action);
                obj.Set("params", bytes);
                obj.Set("date", DateTime.Now);
                PlayerIO.BigDB.CreateObject("Chat", null, obj, null);
            }
        }

        private void handleCreateGame(Player player,Message message)
        {
            DatabaseObject obj = new DatabaseObject();
            String type = message.GetString(0);
            int slots = message.GetInteger(1);
            String author = player.name;
            obj.Set("type", type);
            obj.Set("authorId", player.ConnectUserId);
            obj.Set("author", author);
            DatabaseArray players = new DatabaseArray();
            players.Add(player.Id);
            obj.Set("slots", slots);
            obj.Set("players", players);
            obj.Set("date", DateTime.Now);
            PlayerIO.BigDB.CreateObject("Games", null, obj,
                delegate(DatabaseObject databaseObject)
                {
                    player.addGame(databaseObject.Key,type,author,slots,players.Count,
                        delegate(DatabaseObject playerObject){
                            
                        });
                });
        }

        private void handleGenericMessage(Player player, Message message)
        {
            Message m = Message.Create("generic");
            message.Add(player.ConnectUserId);
            Broadcast(message);
        }

        // This method is called when a player sends a message into the server code
        public override void GotMessage(Player player, Message message)
        {
            base.GotMessage(player, message);
			switch(message.Type) {
                case "name":
                    if (player.name != message.GetString(0))
                    {
                        player.name = message.GetString(0);
                        Broadcast("player", player.ConnectUserId, "name", player.name);
                    }
                    break;
                case "profilePicture":
                    player.profilePicture = message.GetByteArray(0);
                    Broadcast("player",player.ConnectUserId,"profilePicture",player.profilePicture);
                    break;
                case "profilePictureAlignment":
                    player.profilePictureAlignment = new DatabaseArray {message.GetDouble(0),message.GetDouble(1)};
                    Broadcast("player", player.ConnectUserId, "profilePictureAlignment", player.profilePictureAlignment[0], player.profilePictureAlignment[1]);
                    break;
                case "score":
                    handleScore(player,message);
                    break;
                case "send":
                    handleMessage(message);
                    break;
                case "createGame":
                    handleCreateGame(player,message);
                    break;
                default:
                    handleGenericMessage(player, message);
                    Console.WriteLine("Received message:",message.Type);
                    break;
			}
		}
	}
}
