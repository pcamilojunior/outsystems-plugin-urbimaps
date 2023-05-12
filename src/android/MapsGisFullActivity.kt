package com.outsystems.plugin.urbimaps

import android.Manifest
import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.location.Location
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.PopupMenu
import android.widget.Spinner
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.lifecycle.lifecycleScope
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.tasks.CancellationToken
import com.google.android.gms.tasks.CancellationTokenSource
import com.google.android.gms.tasks.OnTokenCanceledListener
import com.google.android.material.switchmaterial.SwitchMaterial
import com.outsystems.experts.neom.R
import ru.dgis.sdk.map.Gesture
import ru.dgis.sdk.map.GestureManager
import ru.dgis.sdk.map.Map
import ru.dgis.sdk.map.MapView
import ru.dgis.sdk.map.MyLocationDirectionBehaviour
import ru.dgis.sdk.map.MyLocationMapObjectSource
import ru.dgis.sdk.map.ScreenPoint
import ru.dgis.sdk.map.TouchEventsObserver
import ru.dgis.sdk.map.createSmoothMyLocationController
import ru.dgis.sdk.navigation.DefaultNavigationControls
import ru.dgis.sdk.navigation.NavigationView
import java.util.Calendar

class MapsGisFullActivity : AppCompatActivity(), TouchEventsObserver {

    private lateinit var mapSource: MyLocationMapObjectSource
    private var map: Map? = null
    private lateinit var mapView: MapView
    private lateinit var contentSearchNavigation: View

    // Navigation Context
    private lateinit var navigationView: NavigationView
    private lateinit var routeTypeSpinner: Spinner
    private lateinit var startNavigationButton: Button
    private var viewModel: NavigationViewModel? = null
    private lateinit var routeEditorView: View
    private lateinit var textClose: TextView
    private var fuseClient: FusedLocationProviderClient? = null
    private lateinit var simulationSwitch: SwitchMaterial

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_maps_full)
        prepareViews()

        mapView = findViewById<MapView>(R.id.mapView).also {
            lifecycle.addObserver(it)
            it.setTouchEventsObserver(this@MapsGisFullActivity)
            it.getMapAsync(this::onMapReady)
            it.showApiVersionInCopyrightView = true
        }

        setupListeners()
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
        initViewModel(map)
    }

    private fun initViewModel(map: Map) {
        val activity = this
        viewModel = NavigationViewModel(SdkContext.context, map, lifecycleScope).also { viewModel ->
            viewModel.messageCallback = {
                Toast.makeText(activity, it, Toast.LENGTH_LONG).show()
            }
            lifecycleScope.launchWhenStarted {
                viewModel.state.collect {
                    navigationView.removeAllViews()
                    when (it) {
                        NavigationViewModel.State.ROUTE_EDITING -> {
                            routeEditorView.visibility = View.VISIBLE
                            navigationView.navigationManager = null
                        }
                        NavigationViewModel.State.NAVIGATION -> {
                            routeEditorView.visibility = View.INVISIBLE
                            navigationView.navigationManager = viewModel.navigationManager
                            navigationView.addView(DefaultNavigationControls(navigationView.context).apply {
                                defaultState = viewModel.navigationType
                                onFinishClicked = {
                                    viewModel.stopNavigation()
                                }
                            })
                        }
                    }
                }
            }
            lifecycleScope.launchWhenStarted {
                viewModel.canStartNavigation.collect {
                    startNavigationButton.isEnabled = it
                }
            }
        }

        //  setupFuseClientLocation()
    }

    private fun setupFuseClientLocation() {
        if (checkPermission()) {
            // todo: request here
            return
        }

        fuseClient = LocationServices.getFusedLocationProviderClient(applicationContext)
        fuseClient?.getCurrentLocation(LocationRequest.PRIORITY_HIGH_ACCURACY, object : CancellationToken() {
            override fun onCanceledRequested(p0: OnTokenCanceledListener) = CancellationTokenSource().token

            override fun isCancellationRequested() = false
        })
            ?.addOnSuccessListener { location: Location? ->
                if (location == null)
                    Toast.makeText(this, "Cannot get location.", Toast.LENGTH_SHORT).show()
                else {
                    val lat = location.latitude
                    val lon = location.longitude
                    viewModel?.onMenuAction(
                        ScreenPoint(lat.toFloat(), lon.toFloat()),
                        NavigationViewModel.MenuAction.SELECT_START_POINT
                    )
                }
            }
    }

    private fun showMenu(point: ScreenPoint) {
        val anchorView = View(this).apply {
            x = point.x
            y = point.y
            layoutParams = ViewGroup.LayoutParams(1, 1)
            mapView.addView(this)
        }

        PopupMenu(this, anchorView, Gravity.CENTER).apply {
            inflate(R.menu.route_points_menu)
            setOnMenuItemClickListener {
                val action = when (it.itemId) {
                    R.id.menuStartPoint -> NavigationViewModel.MenuAction.SELECT_START_POINT
                    R.id.menuFinishPoint -> NavigationViewModel.MenuAction.SELECT_FINISH_POINT
                    R.id.menuClearPoints -> NavigationViewModel.MenuAction.CLEAR_POINTS
                    else -> null
                }
                if (action != null) {
                    viewModel?.onMenuAction(point, action)
                }
                mapView.removeView(anchorView)
                true
            }
            setOnDismissListener {
                mapView.removeView(anchorView)
            }
        }.show()
    }


    override fun onLongTouch(point: ScreenPoint) {
        val viewModel = viewModel ?: return
        if (viewModel.state.value != NavigationViewModel.State.ROUTE_EDITING) {
            return
        }
        showMenu(point)
    }

    override fun onTap(point: ScreenPoint) {
        viewModel?.onTap(point)
    }

    override fun onBackPressed() {
        viewModel?.let {
            if (it.state.value == NavigationViewModel.State.NAVIGATION) {
                it.stopNavigation()
                return
            }
        }
        super.onBackPressed()
    }

    override fun onDestroy() {
        super.onDestroy()
        viewModel?.close()
    }

    private fun subscribeGestureSwitches(gm: GestureManager) {
        gm.enableGesture(Gesture.ROTATION)
        gm.enableGesture(Gesture.SHIFT)
        gm.enableGesture(Gesture.SCALING)
        gm.enableGesture(Gesture.TILT)
    }

    private fun setupListeners() {
        //Hide keyboard
        window?.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN)
        textClose.setOnClickListener { finish() }
        startNavigationButton.setOnClickListener { viewModel?.startNavigation() }

        simulationSwitch.setOnCheckedChangeListener { _, isChecked ->
            viewModel?.useSimulation = isChecked
        }
    }

    private fun prepareViews() {
        contentSearchNavigation = findViewById(R.id.contentSearchNavigation)
        startNavigationButton = findViewById(R.id.startButton)
        navigationView = findViewById(R.id.navigationView)
        routeTypeSpinner = findViewById(R.id.routeTypeSpinner)
        routeEditorView = findViewById(R.id.routeEditorView)
        textClose = findViewById(R.id.textClose)
        simulationSwitch = findViewById(R.id.simulationSwitch)
        val longTapText = findViewById<TextView>(R.id.availabilityTextView)

        textClose.setTextColor(getColorText())
        longTapText.setTextColor(getColorText())

        setupSpinnerRouteType()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == SearchActivity.SEARCH_RESULT_CODE && data != null) {
            val resultData = data.extras?.getSerializable(SearchActivity.SEARCH_RESULT) as? SearchActivity.SearchResult?
            if (resultData?.title != null && resultData.subtitle != null) {
                setSearchResultOnPoints(resultData)
            }
        }
    }

    @SuppressLint("SetTextI18n")
    private fun setSearchResultOnPoints(result: SearchActivity.SearchResult) {
        when(result.searchType) {
            SearchType.START_POINT -> {
                viewModel?.onMenuAction(ScreenPoint(result.lat.toFloat(), result.long.toFloat()),  NavigationViewModel.MenuAction.SELECT_START_POINT)
            }
            SearchType.END_POINT -> {
                viewModel?.onMenuAction(ScreenPoint(result.lat.toFloat(), result.long.toFloat()), NavigationViewModel.MenuAction.SELECT_FINISH_POINT)
            }
            else -> {}
        }
    }

    private fun getColorText(): Int {
        val c = Calendar.getInstance()
        return when (c.get(Calendar.HOUR_OF_DAY)) {
            in 0..11 -> Color.parseColor("#1182fd")
            in 12..15 -> Color.parseColor("#1182fd")
            in 16..20 -> Color.parseColor("#1182fd")
            in 21..23 -> Color.parseColor("#ffffff")
            else -> Color.parseColor("#ffffff")
        }
    }

    private fun setupSpinnerRouteType() {
        routeTypeSpinner.apply {
            adapter = ArrayAdapter.createFromResource(
                context,
                R.array.route_search_types,
                android.R.layout.simple_spinner_item
            ).apply {
                setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
            }
            onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onNothingSelected(parent: AdapterView<*>?) {}
                override fun onItemSelected(
                    parent: AdapterView<*>?,
                    view: View?,
                    pos: Int,
                    id: Long
                ) {
                    (parent?.getChildAt(0) as? TextView)?.setTextColor(Color.BLACK)
                    viewModel?.routeType = when (pos) {
                        1 -> NavigationViewModel.RouteType.PEDESTRIAN
                        2 -> NavigationViewModel.RouteType.BICYCLE
                        else -> NavigationViewModel.RouteType.CAR
                    }
                }
            }
        }
    }

    private fun checkPermission(): Boolean = ActivityCompat.checkSelfPermission(
        applicationContext,
        Manifest.permission.ACCESS_FINE_LOCATION
    ) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(
        applicationContext,
        Manifest.permission.ACCESS_COARSE_LOCATION
    ) != PackageManager.PERMISSION_GRANTED
}