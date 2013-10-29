var camera, renderer, scene;
var WIDTH = 500, HEIGHT = 500;
var time = 0;
var frames = new Array();
var saveFrames = false;
var frameLength = 1000/30;

var circles = new Array();

init();
animate();


function init() {
	renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true});
	renderer.setSize( 500, 500 );
	document.getElementById( 'container' ).appendChild( renderer.domElement );
	
	scene = new THREE.Scene();
	camera = new THREE.OrthographicCamera( WIDTH / -2, WIDTH / 2, HEIGHT / 2, HEIGHT / - 2, - 5000, 5000 );

	var circleGeom = new THREE.CircleGeometry( WIDTH / 2, 60 );
	var firstCircle = new THREE.Mesh( circleGeom, new THREE.MeshBasicMaterial({color:0xFFFFFF}) );
	scene.add( firstCircle );

	circles.push( firstCircle );

	var theParent = firstCircle;

	for ( var i=0; i<16; i++ ) {
		var circleGeom = new THREE.CircleGeometry( ( WIDTH - i * 30 ) / 2, 60 );
		var circleMesh = new THREE.Mesh( circleGeom, new THREE.MeshBasicMaterial({color:(i%2==0)?0x000000:0xFFFFFF}) );
		// var circleMesh = new THREE.Mesh( circleGeom, new THREE.MeshBasicMaterial({color:0x000000}) );
		// circleMesh.scale.set( .9, .9, .9 );
		circleMesh.position.z = 1;
		circleMesh.rotation.z = Math.PI * .125;
		theParent.add( circleMesh );
		circleMesh.position.y = 10;
		theParent = circleMesh;

		circles.push( circleMesh );
	}

	$('#download').hide()
	$('#download').on( 'click', saveFramesToZip );

	initGUI();

}

function initGUI() {

	gui = new dat.GUI({
		height: 1000,
		width:300
	});
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
	location.href = "data:application/zip;base64,"+zip.generate();
}

function animate() {

	// requestAnimationFrame( animate );
	setTimeout( function() {
        requestAnimationFrame( animate );
    }, frameLength );

    for ( var i=0; i<circles.length; i++ ) {
    	circles[i].rotation.z += .01;
    }

	TWEEN.update( time );
	time += frameLength;
	renderer.render(scene, camera);

	if ( saveFrames ) {
		frames.push( renderer.domElement.toDataURL("image/png").replace(/^data:image\/(png|jpg);base64,/, "") );
	}

}