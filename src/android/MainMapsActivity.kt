package com.outsystems.plugin.urbimaps

import android.content.Intent
import android.os.Bundle
import android.text.InputType
import android.view.View
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity
import com.outsystems.experts.neom.R
import com.outsystems.plugin.urbimaps.SearchActivity.Companion.SEARCH_RESULT
import com.outsystems.plugin.urbimaps.SearchActivity.Companion.SEARCH_RESULT_CODE
import ru.dgis.sdk.coordinates.Bearing
import ru.dgis.sdk.coordinates.GeoPoint
import ru.dgis.sdk.geometry.GeoPointWithElevation
import ru.dgis.sdk.map.CameraAnimationType
import ru.dgis.sdk.map.CameraPosition
import ru.dgis.sdk.map.Gesture
import ru.dgis.sdk.map.GestureManager
import ru.dgis.sdk.map.Map
import ru.dgis.sdk.map.MapObjectManager
import ru.dgis.sdk.map.MapView
import ru.dgis.sdk.map.Marker
import ru.dgis.sdk.map.MarkerOptions
import ru.dgis.sdk.map.MyLocationDirectionBehaviour
import ru.dgis.sdk.map.MyLocationMapObjectSource
import ru.dgis.sdk.map.Tilt
import ru.dgis.sdk.map.Zoom
import ru.dgis.sdk.map.createSmoothMyLocationController
import ru.dgis.sdk.map.imageFromResource
import ru.dgis.sdk.seconds

class MainMapsActivity : AppCompatActivity() {

    private lateinit var mapSource: MyLocationMapObjectSource
    private var map: Map? = null
    private lateinit var mapView: MapView
    private lateinit var editText: EditText
    private lateinit var contentBack: View
    private lateinit var navigationAction: View

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)
        editText = findViewById(R.id.edtSearch)
        contentBack = findViewById(R.id.contentBack)
        navigationAction = findViewById(R.id.navigationAction)
        editText.inputType = InputType.TYPE_NULL

        mapView = findViewById<MapView>(R.id.mapView).also {
            it.getMapAsync(this::onMapReady)
            it.showApiVersionInCopyrightView = true
        }

        setupListeners()
    }

    private fun setupListeners() {
        editText.setOnClickListener {
            startActivityForResult(SearchActivity.newInstance(this, SearchType.DEFAULT), SEARCH_RESULT_CODE)
        }
        contentBack.setOnClickListener {
            finish()
        }

        navigationAction.setOnClickListener {
            startActivity(Intent(this, MapsGisFullActivity::class.java))
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == SEARCH_RESULT_CODE && data != null) {
            val resultData = data.extras?.getSerializable(SEARCH_RESULT) as? SearchActivity.SearchResult?
            if (resultData?.lat != null && resultData.lat != null) {
                val lat = resultData.lat
                val long = resultData.long
                setSearchResultOnMaps(lat, long)
            }
        }
    }

    private fun setSearchResultOnMaps(lat: Double, long: Double) {
       val cameraPosition = CameraPosition(
            point = GeoPoint(lat, long),
            zoom = Zoom(10.0f),
            tilt = Tilt(25.0f),
            bearing = Bearing(85.0)
        )

        val marker = Marker(
            MarkerOptions(
                position = GeoPointWithElevation(
                    lat, long
                ),
                icon = imageFromResource(SdkContext.context, R.drawable.ic_location)
            )
        )

        map?.let {
            MapObjectManager(it).addObject(marker)
        }

        map?.camera?.move(cameraPosition, 2.seconds, CameraAnimationType.LINEAR)
    }

    private fun onMapReady(map: Map) {
        this.map = map
        val gestureManager = checkNotNull(mapView.gestureManager)
        subscribeGestureSwitches(gestureManager)

        mapSource = MyLocationMapObjectSource(
            SdkContext.context,
            MyLocationDirectionBehaviour.FOLLOW_MAGNETIC_HEADING,
            createSmoothMyLocationController()
        )
        map.addSource(mapSource)
    }

    private fun subscribeGestureSwitches(gm: GestureManager) {
        gm.enableGesture(Gesture.ROTATION)
        gm.enableGesture(Gesture.SHIFT)
        gm.enableGesture(Gesture.SCALING)
        gm.enableGesture(Gesture.TILT)
    }
}