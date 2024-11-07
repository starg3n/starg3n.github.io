export default class Plugin extends Patch{
	name = "Disable Judge Scores"
	version = "22.03.05"
	description = ""
	author = "Katie Frogs"
	
	load(){
		this.addEdits(
			new EditFunction(CanvasDraw.prototype, "score").load(str => {
				return ""
			}),
			new EditFunction(View.prototype, "refresh").load(str => {
				return plugins.strReplace(str, 'this.assets.drawAssets("notes")', "")
			})
		)
	}
}
