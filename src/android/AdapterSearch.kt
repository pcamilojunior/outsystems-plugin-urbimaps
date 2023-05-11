package com.outsystems.plugin.urbimaps

import android.annotation.SuppressLint
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.outsystems.experts.neom.R
import ru.dgis.sdk.directory.DirectoryObject

class AdapterSearch(
    private val adapterSearchListener: AdapterSearchListener
) : RecyclerView.Adapter<AdapterSearch.ViewHolder>() {

    private var data: List<DirectoryObject> = listOf()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_search, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val data = data[position]
        holder.onBind(data)
    }

    override fun getItemCount(): Int = data.size

    @SuppressLint("NotifyDataSetChanged")
    fun setData(data: List<DirectoryObject> = listOf()) {
        this.data = data
        notifyDataSetChanged()
    }

    inner class ViewHolder(ItemView: View) : RecyclerView.ViewHolder(ItemView) {

        private val locationTitle: TextView = itemView.findViewById(R.id.locationTitle)
        private val locationDescription: TextView = itemView.findViewById(R.id.locationDescription)

        fun onBind(item: DirectoryObject) {
            locationTitle.text = item.title
            locationDescription.text = item.subtitle

            itemView.setOnClickListener {
                adapterSearchListener.onItemClicked(item = item)
            }
        }
    }
}

interface AdapterSearchListener {
    fun onItemClicked(item: DirectoryObject)
}