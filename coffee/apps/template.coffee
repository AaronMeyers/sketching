class Scene

	constructor: (options) ->

		@WIDTH = if options.width != undefined then options.width else 500
		@HEIGHT = if options.height != undefined then options.height else 500

		@renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true, antialias:true})
		@renderer.setSize options.width, options.height
		$('#container').append @renderer.domElement

		@scene = new THREE.Scene()
		@camera = new THREE.OrthographicCamera( @WIDTH / -2, @WIDTH / 2, @HEIGHT / 2, @HEIGHT / - 2, - 5000, 5000 )
		@frameLength = 1000/30
		@time = 0
		@frames = []
		@saveFrames = false

	init: ->
		@update()

	update: =>
		setTimeout (=>
			requestAnimationFrame( @update )
		), @frameLength

		TWEEN.update @time
		@time += @frameLength
		@renderer.render @scene, @camera

		if @saveFrames
			frame = @renderer.domElement.toDataURL().replace /^data:image\/(png|jpg);base64,/, ""
			@frames.push frame