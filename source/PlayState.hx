package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.actions.FlxActionSet;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.math.FlxPoint;

class PlayState extends FlxState
{
	public var seesPlayer:Bool;
	public var playerPosition:FlxPoint;
	var enemies:FlxTypedGroup<Enemy>;
	var coins:FlxTypedGroup<Coin>;
	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;

	override public function create()
	{
		map = new FlxOgmo3Loader(AssetPaths.TurnBasedRPG__ogmo, AssetPaths.room_001__json);
		walls = map.loadTilemap(AssetPaths.tiles__png, "walls");
		walls.follow();
		walls.setTileProperties(1, FlxObject.NONE);
		walls.setTileProperties(2, FlxObject.ANY);
		add(walls);
		coins = new FlxTypedGroup<Coin>();
		add(coins);
		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);
		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);
		FlxG.camera.follow(player, TOPDOWN, 1);
		super.create();
	}

	function placeEntities(entity:EntityData)
	{
		var x = entity.x;
		var y = entity.y;

		switch (entity.name)
		{
			case "player":
				player.setPosition(x, y);

			case "coin":
				coins.add(new Coin(x + 4, y + 4));

			case "enemy":
				enemies.add(new Enemy(x + 4, y, REGULAR));

			case "boss":
				enemies.add(new Enemy(x + 4, y, BOSS));
		}
	}

	function playerTouchCoin(player:Player, coin:Coin)
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
		{
			coin.kill();
		}
	}

	function checkEnemyVision(enemy:Enemy)
	{
		if (walls.ray(enemy.getMidpoint(), player.getMidpoint()))
		{
			enemy.seesPlayer = true;
			enemy.playerPosition = player.getMidpoint();
		}
		else
		{
			enemy.seesPlayer = false;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.collide(enemies, walls);
		enemies.forEachAlive(checkEnemyVision);
		FlxG.collide(player, walls);
		FlxG.overlap(player, coins, playerTouchCoin);
	}
}
