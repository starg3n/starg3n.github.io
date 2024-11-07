export default class Plugin extends Patch{
	name = "Default patches"
	version = "23.01.11"
	description = "Opens the correct privacy file. Suppresses multiplayer errors. Allows importing assets through gdrive. Does not include the custom code in loader.js, which uses correct paths for api files."
	author = "Katie Frogs"
	
	load(){
		this.addEdits(
			new EditFunction(CustomSongs.prototype, "openPrivacy").load(str => {
				return plugins.insertAfter(str, 'open("privacy', `.txt`)
			}),
			new EditFunction(Account.prototype, "openPrivacy").load(str => {
				return plugins.insertAfter(str, 'open("privacy', `.txt`)
			}),
			new EditFunction(ImportSongs.prototype, "load").load(str => {
				return plugins.strReplace(str, '!this.limited && (path.indexOf("/taiko-web assets/")', `(path.indexOf("/taiko-web assets/")`)
			}),
			new EditFunction(LoadSong.prototype, "run").load(str => {
				str = plugins.strReplace(str, ' + "img/touch_drum.png"', ` + (gameConfig.assets_no_dir ? "touch_drum.png" : "img/touch_drum.png")`)
				return plugins.strReplace(str, ' + "img/"', ` + (gameConfig.assets_no_dir ? "" : "img/")`)
			}),
			new EditFunction(LoadSong.prototype, "loadSongBg").load(str => {
				return plugins.strReplace(str, ' + "img/"', ` + (gameConfig.assets_no_dir ? "" : "img/")`)
			})
		)
	}
	start(){
		p2.disable()
	}
	stop(){
		p2.enable()
	}
}
