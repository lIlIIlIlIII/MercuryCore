<script lang="ts">
	import AdminLink from "$components/AdminLink.svelte"
	import Head from "$components/Head.svelte"
	import SidebarShell from "$components/SidebarShell.svelte"
	import Tab from "$components/Tab.svelte"
	import TabData from "$components/TabData"
	import TabNav from "$components/TabNav.svelte"
	import { _ } from "svelte-i18n"

	export let data

	$: assetTypes = [
		[$_("Global.Shirts"), "🧥", "11"],
		[$_("Global.T-Shirts"), "👕", "2"],
		[$_("Global.Pants"), "👖", "12"],
		[$_("Global.Decals"), "🖼️", "13"]
	]

	// TODO: when using $: tabs cant be switched
	let tabData = TabData(data.url, [$_("Global.Create"), $_("Global.Creations")])
	let tabData2 = TabData(data.url, [
		$_("Global.Shirts"), 
		$_("Global.T-Shirts"), 
		$_("Global.Pants"), 
		$_("Global.Decals")
	])
</script>

<Head name={data.siteName} title="{$_("Global.Create")}" />

<h1 class="text-center pb-4">{$_("Global.Create")}</h1>

<div class="px-4 pt-6">
	<SidebarShell bind:tabData space>
		<div>
			<Tab {tabData} class="grid lg:grid-cols-4 gap-4">
				{#each assetTypes as asset, num}
					<AdminLink
						href="/develop/create?asset={asset[2]}"
						emoji={asset[1]}
						{num}
						total={assetTypes.length}
						name={asset[0]} />
				{/each}
			</Tab>

			<Tab {tabData}>
				<TabNav bind:tabData={tabData2} justify />
				<form
					on:submit|preventDefault
					action="/character?tab={tabData.currentTab}"
					class="pb-4">
					<input
						type="hidden"
						name="tab"
						value={tabData.currentTab} />
					<div class="input-group">
						<input
							type="text"
							name="q"
							placeholder="{$_("Pages.Develop.SearchPlaceholder")}"
							aria-label="{$_("Pages.Develop.SearchPlaceholder")}"
							aria-describedby="button-addon2" />
						<button
							class="btn btn-secondary"
							aria-label="{$_("Global.Search")}"
							id="button-addon2">
							<fa fa-search />
						</button>
					</div>
				</form>
			</Tab>
		</div>
	</SidebarShell>
</div>
