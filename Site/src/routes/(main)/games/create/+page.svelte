<script lang="ts">
	import Head from "$components/Head.svelte"
	import Form from "$components/forms/Form.svelte"
	import Input from "$components/forms/Input.svelte"
	import Textarea from "$components/forms/Textarea.svelte"
	import beautifyCurrency from "$lib/beautifyCurrency"
	import { superForm } from "sveltekit-superforms/client"
	import { _ } from "svelte-i18n"

	export let data

	const formData = superForm(data.form)
	export const snapshot = formData

	const [, c1, c2] = beautifyCurrency(data.price)
</script>

<Head name={data.siteName} title="{$_("Pages.Games.Create.CreateAPlace")}" />

<h1 class="text-center">{$_("Pages.Games.Create.CreateAPlace")}</h1>

<Form
	{formData}
	nopad
	class="ctnr pt-12 max-w-200 light-text"
	submit="{$_("Labels.Create")} ({data.currencySymbol}{c1}{c2 ? '.' : ''}{c2})">
	<Input
		{formData}
		name="name"
		label="{$_("Pages.Games.Create.PlaceName")}"
		placeholder="{$_("Pages.Games.Create.PlaceNamePlaceholder")}" />
	<Textarea
		{formData}
		name="description"
		label="{$_("Labels.Description")}"
		placeholder="{$_("Pages.Games.Create.DescriptionPlaceholder")}" />
	<Input
		{formData}
		name="serverIP"
		label="{$_("Pages.Games.Create.ServerIp")}"
		placeholder="{$_("Pages.Games.Create.ServerIpPlaceholder")}" />
	<Input
		{formData}
		type="number"
		name="serverPort"
		label="{$_("Pages.Games.Create.ServerPort")}"
		placeholder="1024-65536"
		help="{$_("Pages.Games.Create.ServerPortHelp")}" />
	<Input
		{formData}
		type="number"
		name="maxPlayers"
		label="{$_("Pages.Games.Create.MaxPlayers")}"
		placeholder="1-99 {$_("Labels.Players")}" />
	<Input
		{formData}
		type="checkbox"
		name="privateServer"
		label="{$_("Pages.Games.Create.PrivateServer")}" />
</Form>
