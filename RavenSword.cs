using System;
using System.Collections;
using UnityEngine;

// Token: 0x02000097 RID: 151
public class RavenSword : MeleeWeapon {
	public float SKEWER_RANGE = 2.4f;

	public float SKEWER_RELEASE_FORCE = 600f;

	public float RAM_FORCE = 400f;

	public GameObject skeweredSoldier;

	public SkinnedMeshRenderer skeweredSoldierMeshRenderer;

	public AudioClip skewerSound;

	public AudioClip tossSound;

	public AudioClip ramSound;

	public Light light;

	private Actor skeweredActor;
}
