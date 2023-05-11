package com.outsystems.plugin.urbimaps

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.widget.EditText
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.outsystems.experts.neom.R
import ru.dgis.sdk.directory.DirectoryObject
import ru.dgis.sdk.directory.SearchManager
import ru.dgis.sdk.directory.SearchQueryBuilder
import java.io.Serializable

class SearchActivity : AppCompatActivity(), AdapterSearchListener {

    private val adapter = AdapterSearch(this)
    private val searchManager = SearchManager.createOnlineManager(context = SdkContext.context)
    private lateinit var edtSearch: EditText
    private lateinit var rvSearch: RecyclerView
    private lateinit var ivBack: ImageView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_search)

        edtSearch = findViewById(R.id.edtSearch)
        rvSearch = findViewById(R.id.rvSearchResult)
        ivBack = findViewById(R.id.ivBack)

        if (savedInstanceState != null) {
            val savedEditTextSearch = savedInstanceState.getString(SEARCH_TEXT_FIELD)
            if (savedEditTextSearch != null) {
                searchAction(savedEditTextSearch)
            }
        }
    }

    override fun onStart() {
        super.onStart()

        edtSearch.addTextChangedListener(object: TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) { searchAction(s.toString()) }
        })

        ivBack.setOnClickListener {
            finish()
        }
    }

    private fun searchAction(text: String) {
        if (text.isEmpty()) {
            adapter.setData(listOf())
        } else {
            val query = SearchQueryBuilder.fromQueryText(text).setPageSize(10).build()
            searchManager.search(query).onResult { searchResult ->
                val data = searchResult.firstPage?.items ?: emptyList()
                setupAdapter(data)
            }
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putString(SEARCH_TEXT_FIELD, edtSearch.text.toString())
    }

    private fun setupAdapter(data: List<DirectoryObject>) {
        adapter.setData(data)
        rvSearch.layoutManager = LinearLayoutManager(this)
        rvSearch.adapter = adapter
    }

    override fun onItemClicked(item: DirectoryObject) {
        val searchResultType = intent.extras?.getString(SEARCH_TYPE) ?: SearchType.DEFAULT.name
        Log.v("TAG", ">>> Item clicked: $item")

        val intent = Intent()
        val result = SearchResult(
            title = item.address?.addressComment,
            subtitle = item.address?.postCode,
            lat = item.markerPosition?.latitude?.value ?: 0.0,
            long = item.markerPosition?.longitude?.value ?: 0.0,
            searchType = SearchType.valueOf(searchResultType)
        )

        intent.putExtra(SEARCH_RESULT, result)
        setResult(20012, intent)
        finish()
    }

    companion object {
        private const val SEARCH_TEXT_FIELD = "SEARCH_TEXT_FIELD"
        const val SEARCH_TYPE = "SEARCH_TYPE"
        const val SEARCH_RESULT = "SEARCH_RESULT"
        const val SEARCH_RESULT_CODE = 20012

        fun newInstance(context: Context, searchType: SearchType): Intent {
            return Intent(
                context,
                SearchActivity::class.java
            ).apply {
                putExtra(SEARCH_TYPE, searchType.name)
            }
        }
    }

    data class SearchResult(
        val title: String?,
        val subtitle: String?,
        val lat: Double,
        val long: Double,
        val searchType: SearchType
    ) : Serializable
}

enum class SearchType : Serializable {
    DEFAULT,
    START_POINT,
    END_POINT
}