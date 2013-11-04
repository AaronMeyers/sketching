class Scene

	WIDTH = HEIGHT = 500

	constructor: (options) ->
		@renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true, antialias:true})
		@renderer.setSize options.width, options.height
		# $(document).append @renderer.domElement

		@scene = new THREE.Scene()
		@camera = new THREE.OrthographicCamera( WIDTH / -2, WIDTH / 2, HEIGHT / 2, HEIGHT / - 2, - 5000, 5000 )
		@frameLength = 1000/30

	update: =>
		console.log 'update'
		setTimeout (=>
			requestAnimationFrame( @update )
			null
		), @frameLength
		null

	# $(document).ready ->
	# 	$('#container').css {'width': WIDTH + 'px', 'height': HEIGHT + 'px'}
	# 	$('#wrapper').css	{'margin-top': (-HEIGHT/2) + 'px'}
	# 	init()
	# 	animate()
	# 	null

	# init = ->
	# 	console.log 'init'
	# 	null

	# animate = ->
	# 	@renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true, antialias:true});
	# 	null