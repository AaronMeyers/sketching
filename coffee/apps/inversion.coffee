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
		@saveFrames = true

	makeWheel: (width, numCircles)->
		node = new THREE.Object3D
		for i in [1..numCircles]
			circleWidth = utils.map( i, 1, numCircles+1, width, 0 )
			color = if i%2==0 then 0x000000 else 0xFFFFFF
			circle = new THREE.Mesh( new THREE.CircleGeometry( circleWidth/2, 100 ), new THREE.MeshBasicMaterial({color:color}) )
			circle.position.z = i*.01
			node.add circle
		return node

	tweenNodePos: (node, pos, time)->
		tween = new TWEEN.Tween {node:node, posX:node.position.x, posY:node.position.y, posZ: node.position.z}
		tween.to {posX:pos.x, posY:pos.y, posZ:pos.z}, time
		tween.easing TWEEN.Easing.Sinusoidal.InOut
		tween.onUpdate ->
			@node.position.set( @posX, @posY, @posZ )
		tween.repeat 1000 
		tween.yoyo true
		tween.start( @time )

	init: ->
		# two wheels
		@wheelL = @makeWheel @WIDTH, 10
		@wheelR = @makeWheel @WIDTH, 10

		# a texture to render each wheel into
		@renderTextureL = new THREE.WebGLRenderTarget @WIDTH, @HEIGHT, { minFilter: THREE.LinearFilter, magFilter: THREE.NearestFilter, format: THREE.RGBAFormat }
		@renderTextureR = new THREE.WebGLRenderTarget @WIDTH, @HEIGHT, { minFilter: THREE.LinearFilter, magFilter: THREE.NearestFilter, format: THREE.RGBAFormat }

		# a scene for each one too
		@sceneL = new THREE.Scene
		@sceneR = new THREE.Scene

		# add the wheels to their respective scenes
		@sceneL.add @wheelL
		@sceneR.add @wheelR

		# position the wheels
		@wheelL.position.x = -@WIDTH/2;
		@wheelR.position.x = @WIDTH/2;

		# make a material with the invert shader
		@shaderMaterial = new THREE.ShaderMaterial(THREE.InvertShader)
		@shaderMaterial.uniforms.tDiffuse1.value = @renderTextureL
		@shaderMaterial.uniforms.tDiffuse2.value = @renderTextureR

		# make a plane to draw the inversion
		@plane = new THREE.Mesh( new THREE.PlaneGeometry( 500, 500 ), @shaderMaterial )
		@scene.add @plane

		# finally, set up some animation for the two wheels
		@animationLength = 2400
		@tweenNodePos @wheelL, new THREE.Vector3( @WIDTH/2, 0, 0 ), @animationLength
		@tweenNodePos @wheelR, new THREE.Vector3( -@WIDTH/2, 0, 0 ), @animationLength

		@update()

	update: =>
		setTimeout (=>
			requestAnimationFrame( @update )
		), @frameLength

		TWEEN.update @time
		@time += @frameLength

		@renderer.render @sceneL, @camera, @renderTextureL, true
		@renderer.render @sceneR, @camera, @renderTextureR, true
		@renderer.render @scene, @camera

		if @saveFrames
			frame = @renderer.domElement.toDataURL().replace /^data:image\/(png|jpg);base64,/, ""
			@frames.push frame
			if @time >= @animationLength
				@saveFramesToZip()
				@saveFrames = false
				$('#download').fadeIn()


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

		blobLink = document.getElementById('download')
		blobLink.download = "frames.zip"
		blobLink.href = window.URL.createObjectURL( zip.generate({type:"blob"} ) )