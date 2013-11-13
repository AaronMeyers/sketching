class Scene

	constructor: (options) ->

		@WIDTH = if options.width != undefined then options.width else 500
		@HEIGHT = if options.height != undefined then options.height else 500

		@renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true, antialias:true})
		@renderer.setSize options.width, options.height
		$('#container').append @renderer.domElement

		@scene = new THREE.Scene()
		@camera = new THREE.PerspectiveCamera 60, @WIDTH/@HEIGHT, .1, 1000
		renderTargetParams = { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBFormat, stencilBuffer: false }
		@composer = new THREE.EffectComposer @renderer, new THREE.WebGLRenderTarget( @WIDTH, @HEIGHT, renderTargetParams )
		@composer.addPass new THREE.RenderPass( @scene, @camera )


		edgeEffect = new THREE.ShaderPass THREE.EdgeShader2
		edgeEffect.uniforms[ 'aspect' ].value.x = @WIDTH
		edgeEffect.uniforms[ 'aspect' ].value.y = @HEIGHT
		@composer.addPass edgeEffect

		effectFXAA = new THREE.ShaderPass THREE.FXAAShader
		effectFXAA.uniforms[ 'resolution' ].value.set( 1 / @WIDTH, 1 / @HEIGHT );
		@composer.addPass effectFXAA

		effect = new THREE.ShaderPass THREE.CopyShader
		effect.renderToScreen = true
		@composer.addPass effect

		@frameLength = 1000/30
		@time = 0
		@frames = []
		@saveFrames = true

	init: ->
		@camera.position.z = 500
		@cubes = []

		numPerSide = 7
		for i in [-numPerSide..numPerSide]
			cube = new THREE.Mesh( new THREE.CubeGeometry( 20, 500, 20 ), new THREE.MeshBasicMaterial({color:0xFFFFFF}) )
			cube.position.x = i * 40
			@spinCube cube, utils.map( i, -numPerSide, numPerSide, 0, 1000 ), if i is numPerSide then true else false
			@scene.add cube
			@cubes.push cube

		@update()

	spinCube: ( cube, delay=1000, saveFrames=false )->
		tween = new TWEEN.Tween {cube:cube, x:cube.rotation.x, scene:@}
		tween.to {x:cube.rotation.x+Math.PI}, 1000
		tween.delay delay
		tween.easing TWEEN.Easing.Quadratic.InOut
		tween.onUpdate ()->
			@cube.rotation.x = @x
		tween.onComplete ()->
			@scene.spinCube @cube
			if saveFrames && @scene.saveFrames
				@scene.saveFrames = false
				@scene.saveFramesToZip()
				$('#download').fadeIn()


		tween.start @time

	saveFramesToZip: ->
		pad = ( n, width, z )->
			z = z || '0'
			n = n + '' 
			return if n.length >= width then n else new Array(width - n.length + 1).join(z) + n

		zip = new JSZip()
		folder = zip.folder( "frames" )
		i = 0
		while i<@frames.length
			folder.file( "frame" + pad(i,3,0) + ".png", @frames[i], {base64:true} )
			i++

		# location.href = "data:application/zip;base64,"+zip.generate();
		blobLink = document.getElementById('download')
		blobLink.download = "frames.zip"
		blobLink.href = window.URL.createObjectURL( zip.generate({type:"blob"} ) )

	update: =>
		setTimeout (=>
			requestAnimationFrame( @update )
		), @frameLength

		TWEEN.update @time
		@time += @frameLength

		# for c, i in @cubes
		# 	c.rotation.x += .05

		# @renderer.render @scene, @camera
		@composer.render()

		if @saveFrames
			frame = @renderer.domElement.toDataURL().replace /^data:image\/(png|jpg);base64,/, ""
			@frames.push frame