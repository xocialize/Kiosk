/**
 *
 *  Materialish
 *  Copyright 2014 Xocialize. All rights reserved.
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 */

'use strict';

// Include Gulp & Tools We'll Use
var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var del = require('del');
var runSequence = require('run-sequence');
var pagespeed = require('psi');

/* This isn't really needed as we're ending up installed on an ios device but... */
var AUTOPREFIXER_BROWSERS = [ 
  'ie >= 10',
  'ie_mob >= 10',
  'ff >= 30',
  'chrome >= 34',
  'safari >= 7',
  'opera >= 23',
  'ios >= 7',
  'android >= 4.4',
  'bb >= 10'
];

// Optimize Images
gulp.task('images', function() {
  return gulp.src('src/images/**/*')
    .pipe($.cache($.imagemin({
      progressive: true,
      interlaced: true
    })))
    .pipe(gulp.dest('assets/images'))
    .pipe($.size({title: 'images'}));
});

// Copy Web Fonts To Dist
gulp.task('fonts', function() {
  return gulp.src(['src/fonts/**'])
    .pipe(gulp.dest('assets/styles/fonts'))
    .pipe($.size({title: 'fonts'}));
});

gulp.task('templates',function(){
	gulp.src('src/templates/**/*.html')
        .pipe($.html2tpl('templates.js' ))
        .pipe(gulp.dest('assets/scripts'));	
});

// Compile and Automatically Prefix Stylesheets
gulp.task('styles', function() {
  // For best performance, don't add Sass partials to `gulp.src`
  return gulp.src([
    'src/styles/**/*.scss'
  ])
    .pipe($.changed('styles', {extension: '.scss'}))
    .pipe($.sass({
      precision: 10
    })
    .on('error', console.error.bind(console)))
    .pipe($.autoprefixer(AUTOPREFIXER_BROWSERS))
    .pipe(gulp.dest('.tmp'))
	.pipe(gulp.dest('src/build/styles'))
    .pipe($.size({title: 'styles'}));
});

gulp.task('html', function () {
    var assets = $.useref.assets({searchPath: '{.tmp,src}'});

    return gulp.src('src/*.html')
        .pipe(assets)
        .pipe($.if('*.js', $.uglify({preserveComments: 'some'})))
        .pipe($.if('*.css', $.csso()))
        .pipe(assets.restore())
        .pipe($.useref())
        .pipe(gulp.dest('.'))
		.pipe($.size({title: 'html'}));
});



// Concatenate And Minify JavaScript
gulp.task('scripts', function() {
  var sources = [
    'node_modules/jquery/dist/jquery.js',
	'node_modules/swiper/dist/js/swiper.jquery.js',
	'src/scripts/app.js'
	
  ];
  return gulp.src(sources)
    .pipe($.concat('main.min.js'))
    .pipe($.uglify({preserveComments: 'some'}))
    // Output Files
    .pipe(gulp.dest('assets/scripts'))
    .pipe($.size({title: 'scripts'}));
});

// Clean Output Directory
gulp.task('clean', del.bind(null, ['.tmp', 'kiosk','dist','src/build']));


// Build Production Files, the Default Task
gulp.task('default', ['clean'], function(cb) {
  runSequence(['styles','templates'], ['html', 'images','fonts'], cb);
});



