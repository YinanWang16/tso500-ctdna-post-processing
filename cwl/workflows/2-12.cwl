#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [cp, /WORK/nscc-gz_material_4/vasp/1-1/3-1.cwl, /WORK/nscc-gz_material_4/vasp/1-1/3-10.cwl, /WORK/nscc-gz_material_4/vasp/1-1/3-11.cwl, /WORK/nscc-gz_material_4/vasp/1-1/3-12.cwl,/WORK/nscc-gz_material_4/vasp/1-1/31.cwl,/WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/INCAR, /WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/POSCAR, /WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/POTCAR, /WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/KPOINTS,/WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/CHG, /WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/CHGCAR, /WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/CONTCAR, /WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/WAVECAR,/WORK/nscc-gz_material_4/vasp/1-1/run_vasp5.sh, /WORK/nscc-gz_material_4/vasp/1-1/check5.sh]
arguments: [/WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/3-1]
inputs:
  cpf1:
    type: File
  cpf2:
    type: File
  cpf3:
    type: File
outputs: 
  cp4:
    type: stdout
stdout: cp4.txt 
  
