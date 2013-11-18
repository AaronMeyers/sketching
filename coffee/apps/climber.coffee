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
		# @composer.addPass edgeEffect

		@ssaoEffect = new THREE.ShaderPass THREE.SSAOShader
		# ssaoEffect.uniforms['cameraNear'].value = @camera.near
		# ssaoEffect.uniforms['cameraFar'].value = @camera.far
		@ssaoEffect.uniforms['size'].value.set @WIDTH, @HEIGHT
		# @composer.addPass @ssaoEffect


		effectFXAA = new THREE.ShaderPass THREE.FXAAShader
		effectFXAA.uniforms[ 'resolution' ].value.set( 1 / @WIDTH, 1 / @HEIGHT );
		@composer.addPass effectFXAA

		effect = new THREE.ShaderPass THREE.CopyShader
		effect.renderToScreen = true
		@composer.addPass effect

		@frameLength = 1000/30
		@time = 0
		@frames = []
		@saveFrames = false

	init: ->
		@animate = true
		@cameraStartY = 100
		@camera.position.set( 0, @cameraStartY, 100 )
		@camera.lookAt( new THREE.Vector3( 0, 200, 0 ) )

		@light = new THREE.PointLight 0xFFFFFF, 1.5, 200
		@scene.add @light
		# @camera.add @light

		@cubeStride = 10
		@totalSeconds = 1.5

		@cubes = []

		@root = new THREE.Object3D
		@root.rotation.y = Math.PI / 4
		@scene.add @root

		numCubes = 50;
		for i in [1..numCubes]
			cube = new THREE.Mesh( new THREE.CubeGeometry( 10000, @cubeStride, @cubeStride ), new THREE.MeshPhongMaterial )
			cube.rotation.y = if i%2==0 then Math.PI/2 else 0
			cube.position.y = i * 10
			@root.add cube
			@cubes.push cube

		@spinStack(@totalSeconds*1000)

		@update()

	spinStack: (totalTime) ->

		numToSpin = 26
		spinLength = totalTime / 3
		lastStart = totalTime - spinLength

		for i in [0..numToSpin-1]
			delay = utils.map( i, 0, numToSpin-1, 0, lastStart )
			@spinCube @cubes[i+10], spinLength, delay


	spinCube: (cube, time=500, delay=0) ->
		# console.log( delay )
		tween = new TWEEN.Tween {cube:cube, rotationY:cube.rotation.y}
		tween.to {rotationY:cube.rotation.y+Math.PI/2}, time
		tween.easing TWEEN.Easing.Quadratic.InOut
		tween.delay delay
		tween.onUpdate ->
			@cube.rotation.y = @rotationY
		tween.start( @time )


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

		@camera.position.y += (@cubeStride) / ( @frameLength * @totalSeconds )
		if ( @camera.position.y >= @cameraStartY + @cubeStride )
			@camera.position.y = @cameraStartY
			for c, i in @cubes
				c.rotation.y -= Math.PI/2
			@spinStack( @totalSeconds * 1000 )
			if ( @saveFrames )
				@saveFrames = false;
				@saveFramesToZip()
				$('#download').fadeIn()

		@light.position.set( @camera.position.x, @camera.position.y + 100, @camera.position.z + 50 )

		@renderer.render @scene, @camera
		@composer.render()

		if @saveFrames
			frame = @renderer.domElement.toDataURL().replace /^data:image\/(png|jpg);base64,/, ""
			@frames.push frame