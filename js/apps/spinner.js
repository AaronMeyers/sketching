var camera, renderer, scene;
var WIDTH, HEIGHT;
var time = 0;
var frames = new Array();
var saveFrames = true;
var frameLength = 1000/30;

var circles = new Array();
var rotationOffset = 0;
var positionOffset;


$(document).ready(function(){

	WIDTH = HEIGHT = 250;
	positionOffset = WIDTH / 25;
	$('#container').css( 'width', WIDTH + 'px' );
	$('#container').css( 'height', HEIGHT + 'px' );
	$('#wrapper').css( 'margin-top', (-HEIGHT/2) + 'px' );

	init();
	animate();
});


function init() {

	renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true, antialias:true});
	renderer.setSize( WIDTH, HEIGHT );
	$('#container').append( renderer.domElement );
	
	scene = new THREE.Scene();
	camera = new THREE.OrthographicCamera( WIDTH / -2, WIDTH / 2, HEIGHT / 2, HEIGHT / - 2, - 5000, 5000 );

	var theParent = scene;
	for ( var i=0; i<16; i++ ) {
		var circleGeom = new THREE.CircleGeometry( ( WIDTH - i * (WIDTH/15) ) / 2, 60 );
		var circleMesh = new THREE.Mesh( circleGeom, new THREE.MeshBasicMaterial({color:(i%2==1)?0x000000:0xFFFFFF}) );
		circleMesh.position.z = 1;
		circleMesh.rotation.z = Math.PI * rotationOffset;
		theParent.add( circleMesh );
		theParent = circleMesh;
		circles.push( circleMesh );
	}

	doSpin();

}

function doSpin() {

	rotationOffset = 0;

	var tween = new TWEEN.Tween(this)
	.to({rotationOffset:2}, 4000)
	.easing( TWEEN.Easing.Quadratic.InOut )
	.onUpdate(function(){
		var positionMod = Math.sin( Math.PI * rotationOffset * .5 );
		for ( var i=0; i<circles.length; i++ ) {
			circles[i].rotation.z = Math.PI * rotationOffset;
			circles[i].position.y = i==0 ? 0 : positionMod * positionOffset;
		}
	})
	.onComplete(function(){
		if ( saveFrames ) {
			saveFrames = false
			saveFramesToZip();
			$('#download').fadeIn();
		}
		doSpin();
	})
	.start();
}

function saveFramesToZip() {
	var pad = function(n, width, z) {
		z = z || '0';
		n = n + '';
		return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
	}

	var zip = new JSZip();
	var folder = zip.folder( "frames" );
	for ( var i=0; i<frames.length; i++ ) {
		folder.file( "frame" + pad(i,3,0) + ".png", frames[i], {base64:true} );
	}

	// location.href = "data:application/zip;base64,"+zip.generate();
	var blobLink = document.getElementById('download');
	blobLink.download = "frames.zip";
	blobLink.href = window.URL.createObjectURL(
		zip.generate({type:"blob"})
	);
}

function animate() {

	setTimeout( function() {
        requestAnimationFrame( animate );
    }, frameLength );

	TWEEN.update( time );
	time += frameLength;
	renderer.render(scene, camera);

	if ( saveFrames ) {
		frames.push( renderer.domElement.toDataURL("image/png").replace(/^data:image\/(png|jpg);base64,/, "") );
	}

}