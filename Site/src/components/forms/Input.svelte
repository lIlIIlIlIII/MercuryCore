<script lang="ts">
	import SubInput from "$components/forms/SubInput.svelte"
	import type { HTMLInputTypeAttribute } from "svelte/elements"

	export let name: string
	export let label = ""
	export let help = ""
	export let after = ""
	export let type: HTMLInputTypeAttribute = "text"

	export let inline = false
	export let column = false
	export let formData: import("sveltekit-superforms").SuperForm<any>
	const { errors } = formData
</script>

<div class="flex flex-wrap {inline ? 'flex-1' : 'pb-8'}">
	{#if label}
		<label for={name} class="w-full {column ? '' : 'md:w-1/4'}">
			{label}
		</label>
	{/if}
	<div
		class="w-full {label && !column
			? 'md:w-3/4'
			: ''} {$$restProps.mainclass || ''}">
		<!-- welp, boilerplate begets boilerplate -->
		{#if after}
			<div class="flex items-center">
				<SubInput {...$$restProps} {name} {type} {formData} />
				{@html after}
			</div>
		{:else}
			<SubInput {...$$restProps} {name} {type} {formData} />
		{/if}

		{#if help}
			<small class="formhelp">
				{help}
			</small>
		{/if}

		{#if $errors[name]}
			<small class="block text-red-5">
				{$errors[name]}
			</small>
		{/if}
	</div>
</div>
