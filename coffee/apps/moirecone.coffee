class MoireCone
	constructor: (options = {}) ->
		@angle			= if options.angle? then options.angle else 50
		@numLines		= if options.numLines? then options.numLines else 20
		@radius 		= if options.radius? then options.radius else 400
		@lineManager 	= new LineManager {maxLines:@numLines}
		@mesh 			= @lineManager.mesh
		@position		= @mesh.position
		@rotation		= @mesh.rotation
		@homeX			= if options.homeX? then options.homeX else 0
		@position.x 	= @homeX

		@makeLines()

	makeLines: ->
		@lineManager.clear()
		for i in [1..@numLines]
			angle = utils.map i, 1, @numLines, -@angle/2, @angle/2
			angle *= Math.PI / 180
			@lineManager.addLine 0, 0, Math.sin( angle ) * @radius, Math.cos( angle ) * @radius
			if i is 1
				@extent = ( 500 / Math.cos( angle ) ) * Math.sin angle

		@lineManager.update()

	setAngle: (angle) ->
		@angle = angle
		@makeLines()



class Scene

	constructor: (options) ->

		@WIDTH = if options.width != undefined then options.width else 500
		@HEIGHT = if options.height != undefined then options.height else 500

		@renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true, antialias:true})
		@renderer.setSize options.width, options.height
		$('#container').append @renderer.domElement

		@scene = new THREE.Scene()
		@camera = new THREE.OrthographicCamera( @WIDTH / -2, @WIDTH / 2, @HEIGHT, 0, - 5000, 5000 )
		@frameLength = 1000/30
		@time = 0
		@frames = []
		@saveFrames = false

	init: ->
		@bigAngle = 28
		@smallAngle = 15
		@angle = @bigAngle
		@cone = new MoireCone {radius:@HEIGHT+100, angle:@angle}
		@scene.add @cone.mesh

		@sideCones = []
		@conesPerSide = 15

		for i in [1..@conesPerSide]
			coneL = new MoireCone {angle:@angle, radius:@HEIGHT+100, homeX:@cone.extent * i}
			coneR = new MoireCone {angle:@angle, radius:@HEIGHT+100, homeX:@cone.extent * -i}
			@scene.add coneL.mesh
			@scene.add coneR.mesh
			if ( i % 2 is 1 )
				coneL.position.y = coneR.position.y = @HEIGHT
				coneL.rotation.z = coneR.rotation.z = Math.PI
			@sideCones.push coneL, coneR

		@tweenToAngle @smallAngle

		@update()

	tweenToAngle: (angle) ->
		tween = new TWEEN.Tween @
		tween.to {angle:angle}, 2000
		tween.easing TWEEN.Easing.Sinusoidal.InOut
		tween.onUpdate ->
			@cone.setAngle @angle
			for i in [1..@conesPerSide]
				@sideCones[(i-1)*2+0].setAngle @angle
				@sideCones[(i-1)*2+0].position.x = i * @cone.extent
				@sideCones[(i-1)*2+1].setAngle @angle
				@sideCones[(i-1)*2+1].position.x = -i * @cone.extent
		tween.onComplete ->
			@tweenToAngle( if @angle is @bigAngle then @smallAngle else @bigAngle )
		tween.start(@time)

	update: =>
		setTimeout (=>
			requestAnimationFrame( @update )
		), @frameLength

		TWEEN.update @time
		@time += @frameLength
		@renderer.render @scene, @camera

		if @saveFrames
			frame = @renderer.domElement.toDataURL.replace /^data:image\/(png|jpg);base64,/, ""
			@frames.push frame